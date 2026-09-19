"""AI chat wrapper with tool-calling so the model can query the app's own
calculators instead of guessing numeric results."""

from __future__ import annotations

import json
import logging
import time

from openai import APIError, APITimeoutError, BadRequestError, OpenAIError

from backend.ai.client import AIClient
from backend.ai.tools import TOOLS, call_tool
from backend.services.errors import CalculatorError

MAX_TOOL_ROUNDS = 8
# Each round can itself take up to the client's 60s request timeout, so
# MAX_TOOL_ROUNDS alone bounds a single /chat request at several minutes.
# This caps total wall-clock time across all rounds combined, tighter than
# round count x per-round timeout, so one stuck conversation can't tie up
# a thread-pool worker (shared with the other synchronous endpoints) for
# anywhere near that long.
MAX_TOTAL_SECONDS = 90.0

logger = logging.getLogger(__name__)


class AIChat:
    """Sends chat completions to the configured NVIDIA model."""

    def __init__(self):
        self._ai = AIClient()
        self.client = self._ai.get_client()
        self.model = self._ai.model

    def ask(self, messages, temperature: float = 0.3, max_tokens: int = 1024, use_tools: bool = True) -> str:
        conversation = list(messages)
        # Scoped to this one ask() call only: if a request with tools gets
        # rejected, later rounds within this same call skip tools too, but
        # the next ask() call (and every other AIChat.ask() caller, e.g. a
        # concurrent request on the shared server-wide instance) starts
        # fresh and tries tools again. A single ambiguous 400 — which isn't
        # guaranteed to mean "this model can't do tool calling" — should
        # not silently disable grounded answers for the rest of the
        # process's life.
        tools_supported = True
        deadline = time.monotonic() + MAX_TOTAL_SECONDS

        for round_index in range(MAX_TOOL_ROUNDS):
            if time.monotonic() >= deadline:
                raise CalculatorError("The AI took too long to respond across multiple tool calls.")

            # The tools-unsupported fallback only runs on the very first
            # round, before any tool_calls/tool-role messages exist in the
            # conversation. A 400 on a later round could be caused by that
            # history itself (many OpenAI-compatible backends require the
            # tools schema to still be present once tool messages exist),
            # so retrying without tools there could just 400 again for an
            # unrelated reason and mask what actually failed.
            message, tools_supported = self._complete(
                conversation, temperature, max_tokens, use_tools, tools_supported, allow_fallback=round_index == 0
            )
            tool_calls = getattr(message, "tool_calls", None) if tools_supported else None
            valid_calls = self._valid_tool_calls(tool_calls)

            if not valid_calls:
                if not message.content:
                    raise CalculatorError("The AI returned an empty response.")
                return message.content

            conversation.append(self._assistant_tool_call_message(message, valid_calls))
            for call_id, name, raw_arguments in valid_calls:
                conversation.append(self._run_tool_call(call_id, name, raw_arguments))

        raise CalculatorError("The AI could not finish after multiple tool calls.")

    def _complete(self, conversation, temperature, max_tokens, use_tools, tools_supported, allow_fallback):
        attempt_with_tools = use_tools and tools_supported
        try:
            response = self._create(conversation, temperature, max_tokens, attempt_with_tools)
        except BadRequestError as exc:
            if attempt_with_tools and allow_fallback:
                # A 400 with tools attached, on the first round of a fresh
                # conversation, most likely means the configured
                # model/endpoint doesn't support function calling; fall
                # back to a plain completion for the rest of this ask()
                # call instead of failing the whole chat turn.
                logger.warning("AI request with tools was rejected (%s); retrying this turn without tools.", exc)
                return self._complete(conversation, temperature, max_tokens, use_tools, False, allow_fallback)
            raise CalculatorError(f"AI request failed: {exc}") from exc
        except (APITimeoutError, APIError, OpenAIError) as exc:
            # Transient failures (timeout, rate limit, connection, 5xx) say
            # nothing about whether tools are supported, so they must not
            # trigger the no-tools fallback.
            raise CalculatorError(f"AI request failed: {exc}") from exc

        choices = getattr(response, "choices", None) or []
        if not choices or not choices[0].message:
            raise CalculatorError("The AI returned an empty response.")
        return choices[0].message, attempt_with_tools

    def _create(self, conversation, temperature, max_tokens, with_tools):
        kwargs = {"tools": TOOLS, "tool_choice": "auto"} if with_tools else {}
        return self.client.chat.completions.create(
            model=self.model,
            messages=conversation,
            max_tokens=max_tokens,
            temperature=temperature,
            top_p=0.9,
            **kwargs,
        )

    def _valid_tool_calls(self, tool_calls):
        """Return (call_id, name, arguments) for each well-formed tool call.

        A call with a missing/blank function name is dropped rather than
        replayed to the API, which could reject it outright. A call with a
        missing/blank id gets a synthesized one unique within this round,
        so two such calls in the same response can't collide on
        tool_call_id="" and have the model misattribute one tool's result
        to the other's call.
        """
        result = []
        for index, call in enumerate(tool_calls or []):
            call_id, name, arguments = self._safe_tool_call_parts(call)
            if not name:
                continue
            if not call_id:
                call_id = f"call_{index}"
            result.append((call_id, name, arguments))
        return result

    def _assistant_tool_call_message(self, message, valid_calls) -> dict:
        return {
            "role": "assistant",
            "content": message.content or "",
            "tool_calls": [
                {
                    "id": call_id,
                    "type": "function",
                    "function": {"name": name, "arguments": arguments or "{}"},
                }
                for call_id, name, arguments in valid_calls
            ],
        }

    def _run_tool_call(self, call_id, name, raw_arguments) -> dict:
        try:
            arguments = json.loads(raw_arguments or "{}")
        except json.JSONDecodeError:
            arguments = {}
        result = call_tool(name, arguments)
        return {
            "role": "tool",
            "tool_call_id": call_id,
            "content": json.dumps(result),
        }

    @staticmethod
    def _safe_tool_call_parts(call):
        """Pull (id, name, arguments) out of a tool_call without raising,
        even if the model returned a malformed or partial tool call."""
        call_id = getattr(call, "id", None) or ""
        function = getattr(call, "function", None)
        name = getattr(function, "name", None) if function is not None else None
        arguments = getattr(function, "arguments", None) if function is not None else None
        return call_id, name, arguments

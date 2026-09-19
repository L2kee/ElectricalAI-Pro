"""AIChat tool-calling loop, tested with a mocked OpenAI client (no live API key needed)."""

import json
import os
import unittest
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

os.environ.setdefault("NVIDIA_API_KEY", "test-key-not-real")

import httpx
from openai import APITimeoutError, BadRequestError  # noqa: E402

from backend.ai.chat import MAX_TOOL_ROUNDS, MAX_TOTAL_SECONDS, AIChat  # noqa: E402
from backend.ai.tools import TOOLS  # noqa: E402
from backend.services.errors import CalculatorError  # noqa: E402


def _make_response(content=None, tool_calls=None):
    message = SimpleNamespace(content=content, tool_calls=tool_calls)
    choice = SimpleNamespace(message=message)
    return SimpleNamespace(choices=[choice])


def _make_tool_call(call_id, name, arguments):
    function = SimpleNamespace(name=name, arguments=json.dumps(arguments))
    return SimpleNamespace(id=call_id, function=function)


def _make_bad_request_error(message="tools not supported"):
    request = httpx.Request("POST", "https://example.com")
    response = httpx.Response(400, request=request)
    return BadRequestError(message, response=response, body=None)


class AIChatToolLoopTests(unittest.TestCase):
    def setUp(self):
        self.chat = AIChat()
        self.chat.client = MagicMock()

    def test_returns_plain_text_response_with_no_tool_calls(self):
        self.chat.client.chat.completions.create.return_value = _make_response(content="Hello.")
        answer = self.chat.ask([{"role": "user", "content": "hi"}])
        self.assertEqual(answer, "Hello.")
        self.chat.client.chat.completions.create.assert_called_once()

    def test_tools_enabled_by_default(self):
        self.chat.client.chat.completions.create.return_value = _make_response(content="Hello.")
        self.chat.ask([{"role": "user", "content": "hi"}])
        call_kwargs = self.chat.client.chat.completions.create.call_args.kwargs
        self.assertEqual(call_kwargs.get("tools"), TOOLS)
        self.assertEqual(call_kwargs.get("tool_choice"), "auto")

    def test_executes_tool_call_and_returns_final_answer(self):
        tool_call = _make_tool_call("call_1", "ohms_law", {"voltage": 120, "resistance": 12})
        first = _make_response(content=None, tool_calls=[tool_call])
        second = _make_response(content="The current is 10 A.")
        self.chat.client.chat.completions.create.side_effect = [first, second]

        answer = self.chat.ask([{"role": "user", "content": "120V across 12 ohms?"}])

        self.assertEqual(answer, "The current is 10 A.")
        self.assertEqual(self.chat.client.chat.completions.create.call_count, 2)

        second_call_messages = self.chat.client.chat.completions.create.call_args_list[1].kwargs["messages"]
        tool_message = next(m for m in second_call_messages if m.get("role") == "tool")
        self.assertEqual(json.loads(tool_message["content"])["current"], 10)
        self.assertEqual(tool_message["tool_call_id"], "call_1")

    def test_tool_error_is_fed_back_as_tool_message_not_raised(self):
        tool_call = _make_tool_call("call_1", "wire_ampacity", {"wire_size": "99 AWG", "temperature_rating": "75"})
        first = _make_response(content=None, tool_calls=[tool_call])
        second = _make_response(content="That wire size isn't supported.")
        self.chat.client.chat.completions.create.side_effect = [first, second]

        answer = self.chat.ask([{"role": "user", "content": "ampacity of 99 AWG"}])

        self.assertEqual(answer, "That wire size isn't supported.")
        second_call_messages = self.chat.client.chat.completions.create.call_args_list[1].kwargs["messages"]
        tool_message = next(m for m in second_call_messages if m.get("role") == "tool")
        self.assertIn("error", json.loads(tool_message["content"]))

    def test_raises_after_max_tool_rounds(self):
        tool_call = _make_tool_call("call_1", "ohms_law", {"voltage": 120, "resistance": 12})
        looping_response = _make_response(content=None, tool_calls=[tool_call])
        self.chat.client.chat.completions.create.return_value = looping_response

        with self.assertRaises(CalculatorError):
            self.chat.ask([{"role": "user", "content": "loop forever"}])

        self.assertEqual(self.chat.client.chat.completions.create.call_count, MAX_TOOL_ROUNDS)

    def test_stops_after_exceeding_total_time_budget(self):
        # MAX_TOOL_ROUNDS alone bounds a request at rounds x the client's
        # per-call timeout (several minutes); the total-time deadline must
        # cut a stuck conversation off well before that, regardless of how
        # many rounds it would otherwise take.
        tool_call = _make_tool_call("call_1", "ohms_law", {"voltage": 120, "resistance": 12})
        looping_response = _make_response(content=None, tool_calls=[tool_call])
        self.chat.client.chat.completions.create.return_value = looping_response

        # monotonic() is read once to set the deadline, then once per round
        # before that round runs. Let round 1 proceed, then report the
        # deadline as exceeded before round 2 would start.
        with patch("backend.ai.chat.time.monotonic", side_effect=[0.0, 0.0, MAX_TOTAL_SECONDS + 1]):
            with self.assertRaises(CalculatorError) as ctx:
                self.chat.ask([{"role": "user", "content": "loop forever"}])

        self.assertIn("took too long", str(ctx.exception))
        self.chat.client.chat.completions.create.assert_called_once()

    def test_raises_on_empty_response(self):
        self.chat.client.chat.completions.create.return_value = _make_response(content=None, tool_calls=None)
        with self.assertRaises(CalculatorError):
            self.chat.ask([{"role": "user", "content": "hi"}])

    def test_use_tools_false_omits_tools_from_the_request(self):
        # Material list generation needs a strict JSON-only response; tools
        # must not be offered to the model for that call.
        self.chat.client.chat.completions.create.return_value = _make_response(content='{"items": []}')

        self.chat.ask([{"role": "user", "content": "material list"}], use_tools=False)

        call_kwargs = self.chat.client.chat.completions.create.call_args.kwargs
        self.assertNotIn("tools", call_kwargs)
        self.assertNotIn("tool_choice", call_kwargs)

    def test_use_tools_false_ignores_tool_calls_in_the_response(self):
        # Even if the model somehow emits tool_calls without tools offered,
        # a use_tools=False response must not enter the tool-execution loop.
        tool_call = _make_tool_call("call_1", "ohms_law", {"voltage": 120, "resistance": 12})
        response = _make_response(content='{"items": []}', tool_calls=[tool_call])
        self.chat.client.chat.completions.create.return_value = response

        answer = self.chat.ask([{"role": "user", "content": "material list"}], use_tools=False)

        self.assertEqual(answer, '{"items": []}')
        self.chat.client.chat.completions.create.assert_called_once()

    def test_malformed_tool_call_missing_function_raises_cleanly(self):
        # Some models/endpoints can emit a tool_call with a null or missing
        # `function`. It must never be replayed to the API (a real endpoint
        # could reject a blank function name outright), so it's dropped;
        # with no content and no valid tool call, that's a clean
        # CalculatorError, not a crash.
        broken_call = SimpleNamespace(id="call_1", function=None)
        response = _make_response(content=None, tool_calls=[broken_call])
        self.chat.client.chat.completions.create.return_value = response

        with self.assertRaises(CalculatorError):
            self.chat.ask([{"role": "user", "content": "hi"}])
        self.chat.client.chat.completions.create.assert_called_once()

    def test_malformed_tool_call_alongside_content_returns_the_content(self):
        # If the model both attempts a broken tool call and writes a real
        # answer in the same turn, the broken call is dropped and the
        # content still comes back, with no wasted second round trip.
        function = SimpleNamespace(name=None, arguments=None)
        broken_call = SimpleNamespace(id="call_1", function=function)
        response = _make_response(content="ok", tool_calls=[broken_call])
        self.chat.client.chat.completions.create.return_value = response

        answer = self.chat.ask([{"role": "user", "content": "hi"}])

        self.assertEqual(answer, "ok")
        self.chat.client.chat.completions.create.assert_called_once()

    def test_falls_back_to_no_tools_on_bad_request_with_tools(self):
        with_tools_call = self.chat.client.chat.completions.create
        with_tools_call.side_effect = [_make_bad_request_error(), _make_response(content="Hello.")]

        answer = self.chat.ask([{"role": "user", "content": "hi"}])

        self.assertEqual(answer, "Hello.")
        self.assertEqual(with_tools_call.call_count, 2)
        first_kwargs = with_tools_call.call_args_list[0].kwargs
        second_kwargs = with_tools_call.call_args_list[1].kwargs
        self.assertIn("tools", first_kwargs)
        self.assertNotIn("tools", second_kwargs)

    def test_bad_request_fallback_does_not_persist_to_the_next_ask_call(self):
        # A single ambiguous 400 must not permanently disable tools for
        # this AIChat instance (it's shared across every request on the
        # server) — the very next ask() call tries tools fresh again.
        self.chat.client.chat.completions.create.side_effect = [
            _make_bad_request_error(),
            _make_response(content="first answer"),
        ]
        self.chat.ask([{"role": "user", "content": "hi"}])

        self.chat.client.chat.completions.create.reset_mock(side_effect=True)
        self.chat.client.chat.completions.create.return_value = _make_response(content="second answer")

        answer = self.chat.ask([{"role": "user", "content": "hi again"}])

        self.assertEqual(answer, "second answer")
        self.chat.client.chat.completions.create.assert_called_once()
        self.assertIn("tools", self.chat.client.chat.completions.create.call_args.kwargs)

    def test_raises_when_both_with_and_without_tools_get_bad_request(self):
        self.chat.client.chat.completions.create.side_effect = [
            _make_bad_request_error(),
            _make_bad_request_error(),
        ]
        with self.assertRaises(CalculatorError):
            self.chat.ask([{"role": "user", "content": "hi"}])
        self.assertEqual(self.chat.client.chat.completions.create.call_count, 2)

    def test_transient_timeout_does_not_trigger_the_no_tools_fallback(self):
        # A timeout says nothing about whether the model supports function
        # calling, so it must fail outright rather than retry without tools.
        request = httpx.Request("POST", "https://example.com")
        self.chat.client.chat.completions.create.side_effect = APITimeoutError(request=request)

        with self.assertRaises(CalculatorError):
            self.chat.ask([{"role": "user", "content": "hi"}])

        self.chat.client.chat.completions.create.assert_called_once()

    def test_bad_request_on_a_later_round_does_not_retry_without_tools(self):
        # Round 1 succeeds with a real tool call, so `conversation` now
        # contains tool_calls/tool-role messages. A 400 on round 2 could be
        # caused by that history rather than by tools being unsupported, so
        # it must raise immediately rather than mask itself behind a second,
        # likely-also-failing retry.
        tool_call = _make_tool_call("call_1", "ohms_law", {"voltage": 120, "resistance": 12})
        first = _make_response(content=None, tool_calls=[tool_call])
        self.chat.client.chat.completions.create.side_effect = [first, _make_bad_request_error("request too large")]

        with self.assertRaises(CalculatorError):
            self.chat.ask([{"role": "user", "content": "hi"}])

        self.assertEqual(self.chat.client.chat.completions.create.call_count, 2)

    def test_multiple_tool_calls_missing_ids_get_unique_synthesized_ids(self):
        # Two tool calls in the same round both missing `id` must not
        # collide on tool_call_id="", or the model could misattribute one
        # tool's result to the other's call.
        function_a = SimpleNamespace(name="ohms_law", arguments=json.dumps({"voltage": 120, "resistance": 12}))
        function_b = SimpleNamespace(
            name="unit_conversion",
            arguments=json.dumps({"category": "length", "from_unit": "ft", "to_unit": "m", "value": 10}),
        )
        call_a = SimpleNamespace(id=None, function=function_a)
        call_b = SimpleNamespace(id=None, function=function_b)
        first = _make_response(content=None, tool_calls=[call_a, call_b])
        second = _make_response(content="done")
        self.chat.client.chat.completions.create.side_effect = [first, second]

        answer = self.chat.ask([{"role": "user", "content": "hi"}])

        self.assertEqual(answer, "done")
        second_call_messages = self.chat.client.chat.completions.create.call_args_list[1].kwargs["messages"]
        tool_messages = [m for m in second_call_messages if m.get("role") == "tool"]
        tool_call_ids = [m["tool_call_id"] for m in tool_messages]
        self.assertEqual(len(tool_call_ids), len(set(tool_call_ids)), "tool_call_ids must be unique")

        assistant_message = next(m for m in second_call_messages if m.get("role") == "assistant")
        assistant_ids = [tc["id"] for tc in assistant_message["tool_calls"]]
        self.assertEqual(assistant_ids, tool_call_ids)


if __name__ == "__main__":
    unittest.main()

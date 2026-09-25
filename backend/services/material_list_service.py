"""Material list generator — structured JSON from the AI."""

from __future__ import annotations

import json
import re

from backend.ai.chat import DEFAULT_MAX_TOKENS, AIChat
from backend.ai.prompts import MATERIAL_LIST_PROMPT, SYSTEM_PROMPT
from backend.services.errors import CalculatorError


class MaterialListService:
    def __init__(self):
        self.chat = AIChat()

    def generate(self, description: str):
        text = (description or "").strip()
        if not text:
            raise CalculatorError("Describe the project first.")

        messages = [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "system", "content": MATERIAL_LIST_PROMPT},
            {
                "role": "user",
                "content": f"Project: {text}",
            },
        ]

        raw = self.chat.ask(
            messages,
            temperature=0.2,
            # Was 1200: the reasoning model spent ~1k tokens thinking first
            # and the JSON got cut off mid-list (finish_reason=length).
            max_tokens=DEFAULT_MAX_TOKENS,
            use_tools=False,
            response_format={"type": "json_object"},
        )
        payload = self._parse(raw)
        return payload

    def _parse(self, raw: str) -> dict:
        cleaned = raw.strip()
        fenced = re.search(r"```(?:json)?\s*(.*?)```", cleaned, re.DOTALL)
        if fenced:
            cleaned = fenced.group(1).strip()

        try:
            data = json.loads(cleaned)
        except json.JSONDecodeError:
            # Even in JSON mode, models often still wrap the object in a
            # sentence ("Here's the material list:" / a trailing note), so
            # the *whole* string isn't valid JSON even though a real JSON
            # object is present somewhere inside it. Fall back to locating
            # that object directly instead of giving up on the first
            # whole-string parse failure.
            extracted = self._extract_json_object(cleaned)
            if extracted is None:
                raise CalculatorError(
                    "The AI did not return a usable material list. Try a more specific project description."
                )
            try:
                data = json.loads(extracted)
            except json.JSONDecodeError as exc:
                raise CalculatorError(
                    "The AI did not return a usable material list. Try a more specific project description."
                ) from exc

        items = data.get("items")
        if not isinstance(items, list) or not items:
            raise CalculatorError("The AI returned an empty material list.")

        normalized = []
        for row in items:
            if not isinstance(row, dict):
                continue
            item = str(row.get("item") or "").strip()
            if not item:
                continue
            try:
                qty = float(row.get("qty") or 0)
            except (TypeError, ValueError):
                qty = 0
            normalized.append(
                {
                    "item": item,
                    "qty": qty,
                    "unit": str(row.get("unit") or "ea").strip() or "ea",
                    "notes": str(row.get("notes") or "").strip(),
                }
            )

        if not normalized:
            raise CalculatorError("The AI returned an empty material list.")

        assumptions = data.get("assumptions") or []
        if not isinstance(assumptions, list):
            assumptions = [str(assumptions)]

        return {"items": normalized, "assumptions": [str(a) for a in assumptions]}

    @classmethod
    def _extract_json_object(cls, text: str) -> str | None:
        """Return the first balanced {...} substring of text that parses as a
        JSON object with an "items" key, or None.

        Tries every "{" as a starting point rather than only the first one:
        the model sometimes opens with a stray extra brace ("{\n{...}") whose
        depth never returns to zero, or leaks reasoning text that contains
        braces of its own before the real object."""
        start = text.find("{")
        while start != -1:
            candidate = cls._balanced_object_at(text, start)
            if candidate is not None:
                try:
                    data = json.loads(candidate)
                except json.JSONDecodeError:
                    data = None
                if isinstance(data, dict) and "items" in data:
                    return candidate
            start = text.find("{", start + 1)
        return None

    @staticmethod
    def _balanced_object_at(text: str, start: int) -> str | None:
        """Return the balanced {...} substring beginning at text[start], or
        None if it never closes. String-aware so a brace inside a quoted
        value (or an escaped quote) doesn't throw off the depth count."""
        depth = 0
        in_string = False
        escape = False
        for index in range(start, len(text)):
            char = text[index]
            if in_string:
                if escape:
                    escape = False
                elif char == "\\":
                    escape = True
                elif char == '"':
                    in_string = False
                continue

            if char == '"':
                in_string = True
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    return text[start : index + 1]

        return None

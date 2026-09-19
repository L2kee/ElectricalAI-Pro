"""Material list generator — structured JSON from the AI."""

from __future__ import annotations

import json
import re

from backend.ai.chat import AIChat
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
            max_tokens=1200,
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

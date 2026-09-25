"""MaterialListService wiring, tested with a mocked AIChat (no live API key needed)."""

import os
import unittest
from unittest.mock import MagicMock, patch

os.environ.setdefault("NVIDIA_API_KEY", "test-key-not-real")

from backend.ai.prompts import TOOL_USE_PROMPT  # noqa: E402
from backend.services.errors import CalculatorError  # noqa: E402
from backend.services.material_list_service import MaterialListService  # noqa: E402


class MaterialListServiceTests(unittest.TestCase):
    def test_disables_tools_and_excludes_tool_use_prompt(self):
        # Material list generation demands a strict JSON-only response, so
        # tools must not be offered and the model must not be told it has any.
        with patch("backend.services.material_list_service.AIChat") as mock_ai_chat_cls:
            mock_chat = MagicMock()
            mock_chat.ask.return_value = '{"items": [{"item": "12 AWG THHN", "qty": 50, "unit": "ft", "notes": ""}]}'
            mock_ai_chat_cls.return_value = mock_chat

            service = MaterialListService()
            result = service.generate("50 ft branch circuit, 12 AWG")

            self.assertEqual(result["items"][0]["item"], "12 AWG THHN")

            messages = mock_chat.ask.call_args.args[0]
            system_contents = [m["content"] for m in messages if m["role"] == "system"]
            self.assertNotIn(TOOL_USE_PROMPT, system_contents)
            self.assertEqual(mock_chat.ask.call_args.kwargs.get("use_tools"), False)


class MaterialListParsingTests(unittest.TestCase):
    """Real failure shapes seen from the reasoning model on 2026-09-22."""

    def setUp(self):
        with patch("backend.services.material_list_service.AIChat"):
            self.service = MaterialListService()

    def test_recovers_from_stray_leading_brace(self):
        raw = '{\n{"items": [{"item": "20A GFCI breaker", "qty": 1, "unit": "ea", "notes": ""}], "assumptions": []}'
        result = self.service._parse(raw)
        self.assertEqual(result["items"][0]["item"], "20A GFCI breaker")

    def test_skips_leaked_reasoning_that_contains_braces(self):
        raw = (
            "Let me think. The user wants {a garage circuit}. I'll list wire first.\n"
            '{"items": [{"item": "12 AWG THHN", "qty": 90, "unit": "ft", "notes": "black, white, green"}],'
            ' "assumptions": ["40 ft run"]}'
        )
        result = self.service._parse(raw)
        self.assertEqual(result["items"][0]["qty"], 90.0)
        self.assertEqual(result["assumptions"], ["40 ft run"])

    def test_truncated_list_still_fails_cleanly(self):
        # What finish_reason=length produced: the object never closes.
        raw = '{"items": [{"item": "EMT 1/2 in", "qty": 4, "unit": "stick", "notes": ""}, {"item": "EMT conn'
        with self.assertRaises(CalculatorError):
            self.service._parse(raw)

    def test_requests_enough_tokens_for_reasoning_plus_json(self):
        with patch("backend.services.material_list_service.AIChat") as mock_ai_chat_cls:
            mock_chat = MagicMock()
            mock_chat.ask.return_value = '{"items": [{"item": "1 gang box", "qty": 1, "unit": "ea", "notes": ""}]}'
            mock_ai_chat_cls.return_value = mock_chat
            MaterialListService().generate("one receptacle")
            self.assertGreaterEqual(mock_chat.ask.call_args.kwargs.get("max_tokens"), 3000)


if __name__ == "__main__":
    unittest.main()

"""MaterialListService wiring, tested with a mocked AIChat (no live API key needed)."""

import os
import unittest
from unittest.mock import MagicMock, patch

os.environ.setdefault("NVIDIA_API_KEY", "test-key-not-real")

from backend.ai.prompts import TOOL_USE_PROMPT  # noqa: E402
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


if __name__ == "__main__":
    unittest.main()

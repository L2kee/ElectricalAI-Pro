"""ChatService wiring, tested with a mocked AIChat (no live API key needed)."""

import os
import unittest
from unittest.mock import MagicMock, patch

os.environ.setdefault("NVIDIA_API_KEY", "test-key-not-real")

from backend.ai.prompts import TOOL_USE_PROMPT  # noqa: E402
from backend.services.chat_service import ChatService  # noqa: E402


class ChatServiceTests(unittest.TestCase):
    def test_includes_tool_use_prompt_for_chat(self):
        # Chat calls AIChat.ask() with tools enabled by default, so the
        # model needs to be told the tools exist.
        with patch("backend.services.chat_service.AIChat") as mock_ai_chat_cls:
            mock_chat = MagicMock()
            mock_chat.ask.return_value = "answer"
            mock_ai_chat_cls.return_value = mock_chat

            service = ChatService()
            result = service.ask("What size wire for a 20A circuit?")

            self.assertEqual(result["answer"], "answer")
            messages = mock_chat.ask.call_args.args[0]
            system_contents = [m["content"] for m in messages if m["role"] == "system"]
            self.assertIn(TOOL_USE_PROMPT, system_contents)

    def test_reuses_conversation_id_across_turns(self):
        with patch("backend.services.chat_service.AIChat") as mock_ai_chat_cls:
            mock_chat = MagicMock()
            mock_chat.ask.return_value = "answer"
            mock_ai_chat_cls.return_value = mock_chat

            service = ChatService()
            first = service.ask("hello")
            second = service.ask("follow-up", conversation_id=first["conversation_id"])

            self.assertEqual(first["conversation_id"], second["conversation_id"])


if __name__ == "__main__":
    unittest.main()

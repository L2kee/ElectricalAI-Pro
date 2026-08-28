"""Chat service with short in-memory history per conversation."""

from __future__ import annotations

from uuid import uuid4

from backend.ai.chat import AIChat
from backend.ai.prompts import SYSTEM_PROMPT
from backend.services.errors import CalculatorError


class ChatService:
    def __init__(self):
        self.chat = AIChat()
        self._history: dict[str, list[dict[str, str]]] = {}

    def ask(self, user_message: str, conversation_id: str | None = None):
        text = (user_message or "").strip()
        if not text:
            raise CalculatorError("Message cannot be empty.")

        conversation_id = conversation_id or str(uuid4())
        history = self._history.setdefault(conversation_id, [])
        history.append({"role": "user", "content": text})
        history[:] = history[-12:]

        messages = [{"role": "system", "content": SYSTEM_PROMPT}, *history]
        answer = self.chat.ask(messages)
        history.append({"role": "assistant", "content": answer})

        return {
            "answer": answer,
            "conversation_id": conversation_id,
        }

"""
ElectricalAI Pro

Chat Service
"""

from backend.ai.chat import AIChat
from backend.ai.prompts import SYSTEM_PROMPT


class ChatService:
    def __init__(self):
        self.chat = AIChat()

    def ask(self, user_message: str):
        messages = [
            {
                "role": "system",
                "content": SYSTEM_PROMPT,
            },
            {
                "role": "user",
                "content": user_message,
            },
        ]

        return self.chat.ask(messages)
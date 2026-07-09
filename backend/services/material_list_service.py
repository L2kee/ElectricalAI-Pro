"""
ElectricalAI Pro

Material List Service
"""

from backend.ai.chat import AIChat
from backend.ai.prompts import SYSTEM_PROMPT


class MaterialListService:

    def __init__(self):
        self.chat = AIChat()

    def generate(self, description: str):

        messages = [
            {
                "role": "system",
                "content": SYSTEM_PROMPT,
            },
            {
                "role": "user",
                "content": (
                    "Generate a material list for this electrical project. "
                    "Return only the suggested materials as a clean list.\n\n"
                    f"Project: {description}"
                ),
            },
        ]

        return self.chat.ask(messages)
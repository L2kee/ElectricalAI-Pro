"""
ElectricalAI Pro

AI Chat Module
"""

from backend.ai.client import AIClient


class AIChat:
    """Handles AI chat requests."""

    def __init__(self):
        self.client = AIClient().get_client()

    def ask(self, messages):
        """Send messages to the NVIDIA AI model."""

        response = self.client.chat.completions.create(
            model="google/diffusiongemma-26b-a4b-it",
            messages=messages,
            max_tokens=1024,
            temperature=1.0,
            top_p=0.95,
        )

        return response.choices[0].message.content
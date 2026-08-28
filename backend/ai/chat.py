"""AI chat wrapper."""

from __future__ import annotations

from openai import APIError, APITimeoutError, OpenAIError

from backend.ai.client import AIClient
from backend.services.errors import CalculatorError


class AIChat:
    """Sends chat completions to the configured NVIDIA model."""

    def __init__(self):
        self._ai = AIClient()
        self.client = self._ai.get_client()
        self.model = self._ai.model

    def ask(self, messages, temperature: float = 0.3, max_tokens: int = 1024) -> str:
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                max_tokens=max_tokens,
                temperature=temperature,
                top_p=0.9,
            )
        except (APITimeoutError, APIError, OpenAIError) as exc:
            raise CalculatorError(f"AI request failed: {exc}") from exc

        choices = getattr(response, "choices", None) or []
        if not choices or not choices[0].message or not choices[0].message.content:
            raise CalculatorError("The AI returned an empty response.")

        return choices[0].message.content

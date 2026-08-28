"""NVIDIA OpenAI-compatible client."""

from __future__ import annotations

import os

from dotenv import load_dotenv
from openai import OpenAI

from backend.services.errors import CalculatorError

load_dotenv()

DEFAULT_MODEL = os.getenv("NVIDIA_MODEL", "meta/llama-3.3-70b-instruct")


class AIClient:
    """Handles communication with NVIDIA's OpenAI-compatible API."""

    def __init__(self):
        api_key = os.getenv("NVIDIA_API_KEY")
        if not api_key:
            raise CalculatorError(
                "NVIDIA_API_KEY is not set. Add it to a .env file in the project root."
            )

        self.model = DEFAULT_MODEL
        self.client = OpenAI(
            base_url="https://integrate.api.nvidia.com/v1",
            api_key=api_key,
            timeout=60.0,
        )

    def get_client(self):
        return self.client

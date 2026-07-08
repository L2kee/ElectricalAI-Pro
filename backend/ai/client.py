"""
ElectricalAI Pro

NVIDIA AI Client
"""

import os

from dotenv import load_dotenv
from openai import OpenAI


load_dotenv()


class AIClient:
    """Handles communication with NVIDIA AI."""

    def __init__(self):
        self.client = OpenAI(
            base_url="https://integrate.api.nvidia.com/v1",
            api_key=os.getenv("NVIDIA_API_KEY"),
        )

    def get_client(self):
        return self.client
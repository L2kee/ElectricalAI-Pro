"""
ElectricalAI Pro

Chat request model.
"""

from pydantic import BaseModel


class ChatRequest(BaseModel):
    message: str
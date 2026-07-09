"""
ElectricalAI Pro

Box Fill request model.
"""

from pydantic import BaseModel


class BoxFillRequest(BaseModel):
    box_volume: float
    conductor_count: int
    conductor_allowance: float
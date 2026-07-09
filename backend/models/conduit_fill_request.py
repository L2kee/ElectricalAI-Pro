"""
ElectricalAI Pro

Conduit Fill request model.
"""

from pydantic import BaseModel


class ConduitFillRequest(BaseModel):
    conduit_area: float
    wire_area: float
    wire_count: int
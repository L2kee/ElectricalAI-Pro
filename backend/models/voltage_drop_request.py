"""
ElectricalAI Pro

Voltage Drop request model.
"""

from pydantic import BaseModel


class VoltageDropRequest(BaseModel):
    current: float
    resistance: float
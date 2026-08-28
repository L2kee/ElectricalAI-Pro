"""Voltage Drop request model."""

from pydantic import BaseModel, Field


class VoltageDropRequest(BaseModel):
    current: float = Field(..., gt=0)
    wire_size: str
    length_ft: float = Field(..., gt=0)
    material: str = "copper"
    voltage: float = Field(120, gt=0)
    phase: str = "single"

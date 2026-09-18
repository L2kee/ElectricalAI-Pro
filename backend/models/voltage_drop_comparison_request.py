"""Voltage Drop Comparison request model."""

from pydantic import BaseModel, Field


class VoltageDropComparisonRequest(BaseModel):
    current: float = Field(..., gt=0)
    length_ft: float = Field(..., gt=0)
    material: str = "copper"
    voltage: float = Field(120, gt=0)
    phase: str = "single"

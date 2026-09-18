"""Transformer Sizing request model."""

from pydantic import BaseModel, Field


class TransformerSizingRequest(BaseModel):
    kva: float = Field(..., gt=0)
    primary_voltage: float = Field(..., gt=0)
    secondary_voltage: float = Field(..., gt=0)
    phase: str = "three"

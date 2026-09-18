"""Unit Conversion request model."""

from pydantic import BaseModel


class UnitConversionRequest(BaseModel):
    category: str
    from_unit: str
    to_unit: str
    value: float

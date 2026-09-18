"""Ohm's Law request model."""

from typing import Optional

from pydantic import BaseModel


class OhmsLawRequest(BaseModel):
    voltage: Optional[float] = None
    current: Optional[float] = None
    resistance: Optional[float] = None

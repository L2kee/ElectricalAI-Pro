"""Circuit Load request model."""

from typing import Optional

from pydantic import BaseModel


class CircuitLoadRequest(BaseModel):
    power: Optional[float] = None
    voltage: Optional[float] = None
    current: Optional[float] = None
    continuous: bool = False

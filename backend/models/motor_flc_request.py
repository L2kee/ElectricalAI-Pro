"""Motor Full-Load Current request model."""

from pydantic import BaseModel


class MotorFlcRequest(BaseModel):
    horsepower: str
    voltage: str
    phase: str = "three"

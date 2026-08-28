"""Wire Ampacity request model."""

from pydantic import BaseModel


class WireAmpacityRequest(BaseModel):
    wire_size: str
    temperature_rating: str
    material: str = "copper"

"""Box Fill request model."""

from pydantic import BaseModel, Field


class BoxFillRequest(BaseModel):
    box_volume: float = Field(..., gt=0)
    conductor_size: str
    conductor_count: int = Field(..., ge=0)
    device_count: int = Field(0, ge=0)
    clamp_count: int = Field(0, ge=0)
    equipment_ground_count: int = Field(0, ge=0)

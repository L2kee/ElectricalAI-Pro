"""Conduit Fill request model."""

from pydantic import BaseModel, Field


class ConduitFillRequest(BaseModel):
    conduit_type: str
    trade_size: str
    wire_size: str
    wire_count: int = Field(..., gt=0)

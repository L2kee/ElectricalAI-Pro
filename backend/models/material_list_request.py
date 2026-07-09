"""
ElectricalAI Pro

Material List request model.
"""

from pydantic import BaseModel


class MaterialListRequest(BaseModel):
    project_description: str
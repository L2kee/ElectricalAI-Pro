"""Single shared instance of each stateless calculator service, used by
both the REST API (backend/api/server.py) and the AI's tool-calling layer
(backend/ai/tools.py), so there's one object per service instead of two."""

from __future__ import annotations

from backend.services.box_fill_service import BoxFillService
from backend.services.circuit_load_service import CircuitLoadService
from backend.services.conduit_fill_service import ConduitFillService
from backend.services.motor_flc_service import MotorFlcService
from backend.services.ohms_law_service import OhmsLawService
from backend.services.transformer_sizing_service import TransformerSizingService
from backend.services.unit_conversion_service import UnitConversionService
from backend.services.voltage_drop_service import VoltageDropService
from backend.services.wire_ampacity_service import WireAmpacityService

ohms_service = OhmsLawService()
voltage_drop_service = VoltageDropService()
wire_ampacity_service = WireAmpacityService()
box_fill_service = BoxFillService()
conduit_fill_service = ConduitFillService()
circuit_load_service = CircuitLoadService()
motor_flc_service = MotorFlcService()
transformer_sizing_service = TransformerSizingService()
unit_conversion_service = UnitConversionService()

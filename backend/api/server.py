"""ElectricalAI Pro FastAPI server."""

from __future__ import annotations

import asyncio
import os

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from backend.models.box_fill_request import BoxFillRequest
from backend.models.chat_request import ChatRequest
from backend.models.circuit_load_request import CircuitLoadRequest
from backend.models.conduit_fill_request import ConduitFillRequest
from backend.models.material_list_request import MaterialListRequest
from backend.models.motor_flc_request import MotorFlcRequest
from backend.models.ohms_law_request import OhmsLawRequest
from backend.models.transformer_sizing_request import TransformerSizingRequest
from backend.models.unit_conversion_request import UnitConversionRequest
from backend.models.voltage_drop_comparison_request import VoltageDropComparisonRequest
from backend.models.voltage_drop_request import VoltageDropRequest
from backend.models.wire_ampacity_request import WireAmpacityRequest
from backend.services.errors import CalculatorError
from backend.services.nec_reference_service import NecReferenceService
from backend.services.registry import (
    box_fill_service,
    circuit_load_service,
    conduit_fill_service,
    motor_flc_service,
    ohms_service,
    transformer_sizing_service,
    unit_conversion_service,
    voltage_drop_service,
    wire_ampacity_service,
)
from backend.services.voltage_drop_comparison_service import VoltageDropComparisonService

app = FastAPI(
    title="ElectricalAI Pro API",
    version="1.0.1",
    description="AI assistant and electrical calculators for ElectricalAI Pro.",
)

_allowed_origins = [
    origin.strip()
    for origin in os.getenv(
        "ALLOWED_ORIGINS", "https://evogencyglobal.com,https://www.evogencyglobal.com"
    ).split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_allowed_origins,
    allow_methods=["*"],
    allow_headers=["*"],
)


def _client_ip(request: Request) -> str:
    """Render (and most PaaS hosts) sit behind a proxy, so the real client IP
    arrives in X-Forwarded-For, not the raw socket address."""
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return get_remote_address(request)


_rate_limit_chat = os.getenv("RATE_LIMIT_CHAT", "10/hour")

limiter = Limiter(key_func=_client_ip)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

voltage_drop_comparison_service = VoltageDropComparisonService(voltage_drop_service)
nec_reference_service = NecReferenceService()

_chat_service = None
_material_list_service = None


def _chat_service_instance():
    global _chat_service
    if _chat_service is None:
        from backend.services.chat_service import ChatService

        _chat_service = ChatService()
    return _chat_service


def _material_list_service_instance():
    global _material_list_service
    if _material_list_service is None:
        from backend.services.material_list_service import MaterialListService

        _material_list_service = MaterialListService()
    return _material_list_service


@app.exception_handler(CalculatorError)
async def calculator_error_handler(_request: Request, exc: CalculatorError):
    return JSONResponse(status_code=400, content={"error": str(exc)})


@app.get("/")
def root():
    return {"message": "Welcome to ElectricalAI Pro API", "version": "1.0.1"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/nec-reference")
def nec_reference():
    return nec_reference_service.get_reference()


@app.post("/chat")
@limiter.limit(_rate_limit_chat)
async def chat_endpoint(request: Request, chat_request: ChatRequest):
    service = _chat_service_instance()
    return await asyncio.to_thread(
        service.ask, chat_request.message, chat_request.conversation_id
    )


@app.post("/ohms-law")
def ohms_law(request: OhmsLawRequest):
    return ohms_service.calculate(
        voltage=request.voltage,
        current=request.current,
        resistance=request.resistance,
    )


@app.post("/voltage-drop")
def voltage_drop(request: VoltageDropRequest):
    return voltage_drop_service.calculate(
        current=request.current,
        wire_size=request.wire_size,
        length_ft=request.length_ft,
        material=request.material,
        voltage=request.voltage,
        phase=request.phase,
    )


@app.post("/conduit-fill")
def conduit_fill(request: ConduitFillRequest):
    return conduit_fill_service.calculate(
        conduit_type=request.conduit_type,
        trade_size=request.trade_size,
        wire_size=request.wire_size,
        wire_count=request.wire_count,
    )


@app.post("/box-fill")
def box_fill(request: BoxFillRequest):
    return box_fill_service.calculate(
        box_volume=request.box_volume,
        conductor_size=request.conductor_size,
        conductor_count=request.conductor_count,
        device_count=request.device_count,
        clamp_count=request.clamp_count,
        equipment_ground_count=request.equipment_ground_count,
    )


@app.post("/wire-ampacity")
def wire_ampacity(request: WireAmpacityRequest):
    return wire_ampacity_service.calculate(
        wire_size=request.wire_size,
        temperature_rating=request.temperature_rating,
        material=request.material,
    )


@app.post("/material-list")
@limiter.limit(_rate_limit_chat)
async def material_list(request: Request, list_request: MaterialListRequest):
    service = _material_list_service_instance()
    return await asyncio.to_thread(service.generate, list_request.project_description)


@app.post("/circuit-load")
def circuit_load(request: CircuitLoadRequest):
    return circuit_load_service.calculate(
        power=request.power,
        voltage=request.voltage,
        current=request.current,
        continuous=request.continuous,
    )


@app.post("/motor-flc")
def motor_flc(request: MotorFlcRequest):
    return motor_flc_service.calculate(
        horsepower=request.horsepower,
        voltage=request.voltage,
        phase=request.phase,
    )


@app.post("/transformer-sizing")
def transformer_sizing(request: TransformerSizingRequest):
    return transformer_sizing_service.calculate(
        kva=request.kva,
        primary_voltage=request.primary_voltage,
        secondary_voltage=request.secondary_voltage,
        phase=request.phase,
    )


@app.post("/unit-conversion")
def unit_conversion(request: UnitConversionRequest):
    return unit_conversion_service.convert(
        category=request.category,
        from_unit=request.from_unit,
        to_unit=request.to_unit,
        value=request.value,
    )


@app.post("/voltage-drop-comparison")
def voltage_drop_comparison(request: VoltageDropComparisonRequest):
    return voltage_drop_comparison_service.compare(
        current=request.current,
        length_ft=request.length_ft,
        material=request.material,
        voltage=request.voltage,
        phase=request.phase,
    )

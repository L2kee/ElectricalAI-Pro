"""ElectricalAI Pro FastAPI server."""

from __future__ import annotations

import asyncio

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from backend.models.box_fill_request import BoxFillRequest
from backend.models.chat_request import ChatRequest
from backend.models.circuit_load_request import CircuitLoadRequest
from backend.models.conduit_fill_request import ConduitFillRequest
from backend.models.material_list_request import MaterialListRequest
from backend.models.ohms_law_request import OhmsLawRequest
from backend.models.voltage_drop_request import VoltageDropRequest
from backend.models.wire_ampacity_request import WireAmpacityRequest
from backend.services.box_fill_service import BoxFillService
from backend.services.circuit_load_service import CircuitLoadService
from backend.services.conduit_fill_service import ConduitFillService
from backend.services.errors import CalculatorError
from backend.services.ohms_law_service import OhmsLawService
from backend.services.voltage_drop_service import VoltageDropService
from backend.services.wire_ampacity_service import WireAmpacityService

app = FastAPI(
    title="ElectricalAI Pro API",
    version="1.0.1",
    description="AI assistant and electrical calculators for ElectricalAI Pro.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

ohms_service = OhmsLawService()
voltage_drop_service = VoltageDropService()
conduit_fill_service = ConduitFillService()
box_fill_service = BoxFillService()
wire_ampacity_service = WireAmpacityService()
circuit_load_service = CircuitLoadService()

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


@app.post("/chat")
async def chat_endpoint(request: ChatRequest):
    service = _chat_service_instance()
    return await asyncio.to_thread(service.ask, request.message, request.conversation_id)


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
async def material_list(request: MaterialListRequest):
    service = _material_list_service_instance()
    return await asyncio.to_thread(service.generate, request.project_description)


@app.post("/circuit-load")
def circuit_load(request: CircuitLoadRequest):
    return circuit_load_service.calculate(
        power=request.power,
        voltage=request.voltage,
        current=request.current,
        continuous=request.continuous,
    )

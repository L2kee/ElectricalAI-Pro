"""
ElectricalAI Pro

FastAPI Server
"""

from fastapi import FastAPI

from backend.models.chat_request import ChatRequest
from backend.models.ohms_law_request import OhmsLawRequest
from backend.models.voltage_drop_request import VoltageDropRequest
from backend.models.conduit_fill_request import ConduitFillRequest
from backend.models.box_fill_request import BoxFillRequest
from backend.models.wire_ampacity_request import WireAmpacityRequest
from backend.models.material_list_request import MaterialListRequest
from backend.models.circuit_load_request import CircuitLoadRequest

from backend.services.chat_service import ChatService
from backend.services.ohms_law_service import OhmsLawService
from backend.services.voltage_drop_service import VoltageDropService
from backend.services.conduit_fill_service import ConduitFillService
from backend.services.box_fill_service import BoxFillService
from backend.services.wire_ampacity_service import WireAmpacityService
from backend.services.material_list_service import MaterialListService
from backend.services.circuit_load_service import CircuitLoadService

app = FastAPI(
    title="ElectricalAI Pro API",
    version="1.0.0",
)

# ============================
# Services
# ============================

chat_service = ChatService()
ohms_service = OhmsLawService()
voltage_drop_service = VoltageDropService()
conduit_fill_service = ConduitFillService()
box_fill_service = BoxFillService()
wire_ampacity_service = WireAmpacityService()
material_list_service = MaterialListService()
circuit_load_service = CircuitLoadService()

# ============================
# Routes
# ============================


@app.get("/")
def root():
    return {
        "message": "Welcome to ElectricalAI Pro API"
    }


@app.post("/chat")
def chat_endpoint(request: ChatRequest):
    return {
        "answer": chat_service.ask(request.message)
    }


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
        resistance=request.resistance,
    )


@app.post("/conduit-fill")
def conduit_fill(request: ConduitFillRequest):
    return conduit_fill_service.calculate(
        conduit_area=request.conduit_area,
        wire_area=request.wire_area,
        wire_count=request.wire_count,
    )


@app.post("/box-fill")
def box_fill(request: BoxFillRequest):
    return box_fill_service.calculate(
        box_volume=request.box_volume,
        conductor_count=request.conductor_count,
        conductor_allowance=request.conductor_allowance,
    )


@app.post("/wire-ampacity")
def wire_ampacity(request: WireAmpacityRequest):
    return wire_ampacity_service.calculate(
        wire_size=request.wire_size,
        temperature_rating=request.temperature_rating,
    )


@app.post("/material-list")
def material_list(request: MaterialListRequest):
    return {
        "materials": material_list_service.generate(
            request.project_description
        )
    }


@app.post("/circuit-load")
def circuit_load(request: CircuitLoadRequest):
    return circuit_load_service.calculate(
        power=request.power,
        voltage=request.voltage,
        current=request.current,
    )
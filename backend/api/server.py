"""
ElectricalAI Pro

FastAPI Server
"""

from fastapi import FastAPI

from backend.models.chat_request import ChatRequest
from backend.models.ohms_law_request import OhmsLawRequest
from backend.models.voltage_drop_request import VoltageDropRequest
from backend.models.conduit_fill_request import ConduitFillRequest

from backend.services.chat_service import ChatService
from backend.services.ohms_law_service import OhmsLawService
from backend.services.voltage_drop_service import VoltageDropService
from backend.services.conduit_fill_service import ConduitFillService

app = FastAPI(
    title="ElectricalAI Pro API",
    version="1.0.0",
)

chat_service = ChatService()
ohms_service = OhmsLawService()
voltage_drop_service = VoltageDropService()
conduit_fill_service = ConduitFillService()


@app.get("/")
def root():
    return {
        "message": "Welcome to ElectricalAI Pro API"
    }


@app.post("/chat")
def chat_endpoint(request: ChatRequest):
    answer = chat_service.ask(request.message)

    return {
        "answer": answer
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
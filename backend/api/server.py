"""
ElectricalAI Pro

FastAPI Server
"""

from fastapi import FastAPI

from backend.models.chat_request import ChatRequest
from backend.models.ohms_law_request import OhmsLawRequest
from backend.models.voltage_drop_request import VoltageDropRequest

from backend.services.chat_service import ChatService
from backend.services.ohms_law_service import OhmsLawService
from backend.services.voltage_drop_service import VoltageDropService

app = FastAPI(
    title="ElectricalAI Pro API",
    version="1.0.0",
)

chat_service = ChatService()
ohms_service = OhmsLawService()
voltage_drop_service = VoltageDropService()


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
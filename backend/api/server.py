"""
ElectricalAI Pro

FastAPI Server
"""

from fastapi import FastAPI

from backend.models.chat_request import ChatRequest
from backend.models.ohms_law_request import OhmsLawRequest

from backend.services.chat_service import ChatService
from backend.services.ohms_law_service import OhmsLawService

app = FastAPI(
    title="ElectricalAI Pro API",
    version="1.0.0",
)

chat_service = ChatService()
ohms_service = OhmsLawService()


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
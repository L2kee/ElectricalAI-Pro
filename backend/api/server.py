"""
ElectricalAI Pro

FastAPI Server
"""

from fastapi import FastAPI

from backend.models.chat_request import ChatRequest
from backend.services.chat_service import ChatService

app = FastAPI(
    title="ElectricalAI Pro API",
    version="1.0.0",
)

chat_service = ChatService()


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
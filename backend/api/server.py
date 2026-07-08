"""
ElectricalAI Pro

FastAPI Server
"""

from fastapi import FastAPI

from backend.ai.chat import AIChat
from backend.models.chat_request import ChatRequest
from backend.ai.prompts import SYSTEM_PROMPT

app = FastAPI(
    title="ElectricalAI Pro API",
    version="1.0.0",
)

chat = AIChat()


@app.get("/")
def root():
    return {
        "message": "Welcome to ElectricalAI Pro API"
    }


@app.post("/chat")
def chat_endpoint(request: ChatRequest):
    messages = [
        {
            "role": "system",
            "content": SYSTEM_PROMPT,
        },
        {
            "role": "user",
            "content": request.message,
        },
    ]

    answer = chat.ask(messages)

    return {
        "answer": answer
    }
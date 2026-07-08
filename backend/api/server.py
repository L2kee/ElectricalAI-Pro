"""
ElectricalAI Pro

FastAPI Server
"""

from fastapi import FastAPI

app = FastAPI(
    title="ElectricalAI Pro API",
    version="1.0.0",
)


@app.get("/")
def root():
    return {
        "message": "Welcome to ElectricalAI Pro API"
    }
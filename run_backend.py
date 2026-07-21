"""
ElectricalAI Pro

Backend Entry Point

This script starts the FastAPI backend.

Development:
    python run_backend.py

Future:
    This file will be packaged into backend.exe using PyInstaller.
"""

import uvicorn
from backend.api.server import app


def main():
    """Start the FastAPI server."""
    uvicorn.run(
        app,
        host="127.0.0.1",
        port=8000,
        reload=False,
        log_level="info",
    )


if __name__ == "__main__":
    main()
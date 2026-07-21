"""
ElectricalAI Pro Launcher

Purpose:
    Main entry point for ElectricalAI Pro.

Responsibilities:
    - Detect Development or Release mode.
    - Start the backend.
    - Wait for backend readiness.
    - Start the frontend.
    - Monitor application lifetime.
    - Shut down cleanly.
"""

from __future__ import annotations

from enum import Enum, auto
from pathlib import Path
import shutil
import subprocess
import sys
import time

import requests


# =============================================================================
# Configuration
# =============================================================================

# Detect whether we're running from source or a packaged executable.
if getattr(sys, "frozen", False):
    # Running from launcher.exe
    PROJECT_ROOT = Path(sys.executable).resolve().parent
else:
    # Running from launcher.py
    PROJECT_ROOT = Path(__file__).resolve().parent

BACKEND_DIRECTORY = PROJECT_ROOT / "backend"
FRONTEND_PATH = PROJECT_ROOT / "frontend"

BACKEND_EXECUTABLE = PROJECT_ROOT / "ElectricalAI-Pro-Backend.exe"
FRONTEND_EXECUTABLE = PROJECT_ROOT / "ElectricalAI-Pro-UI.exe"

BACKEND_URL = "http://127.0.0.1:8000"
BACKEND_HEALTH_ENDPOINT = "/openapi.json"

BACKEND_STARTUP_TIMEOUT = 30
BACKEND_RETRY_INTERVAL = 0.25

FLUTTER_DEVICE = "windows"

# Leave as None to use Flutter from the system PATH.
# Set this only if Flutter cannot be located automatically.
FLUTTER_EXECUTABLE: str | None = None


class RunMode(Enum):
    DEVELOPMENT = auto()
    RELEASE = auto()


def log_info(message: str) -> None:
    """Display an informational message."""
    print(f"[INFO] {message}")


def detect_mode() -> RunMode:
    """Detect Development or Release mode."""

    if (
        BACKEND_DIRECTORY.is_dir()
        and FRONTEND_PATH.is_dir()
        and (PROJECT_ROOT / "venv").is_dir()
    ):
        return RunMode.DEVELOPMENT

    if (
        BACKEND_EXECUTABLE.is_file()
        and FRONTEND_EXECUTABLE.is_file()
    ):
        return RunMode.RELEASE

    raise RuntimeError(
        "Unable to determine launcher mode.\n"
        "Expected:\n"
        "Development -> backend/, frontend/, venv/\n"
        "Release -> backend.exe + frontend.exe"
    )


def start_backend(mode: RunMode) -> subprocess.Popen:
    """Start the backend."""

    if mode == RunMode.DEVELOPMENT:

        log_info("Starting backend...")
        log_info("Development mode detected.")
        log_info("Launching FastAPI...")

        command = [
            sys.executable,
            "-m",
            "uvicorn",
            "backend.api.server:app",
            "--reload",
        ]

        process = subprocess.Popen(
            command,
            cwd=PROJECT_ROOT,
        )

        log_info(f"Backend started (PID {process.pid}).")
        return process

    log_info("Starting packaged backend...")

    process = subprocess.Popen(
        [str(BACKEND_EXECUTABLE)],
        cwd=PROJECT_ROOT,
    )

    log_info(f"Backend started (PID {process.pid}).")
    return process


def wait_for_backend(
    url: str = BACKEND_URL,
    timeout: int = BACKEND_STARTUP_TIMEOUT,
) -> None:
    """Wait until the backend is responding."""

    log_info("Waiting for backend...")

    deadline = time.time() + timeout

    while time.time() < deadline:
        try:
            response = requests.get(
                f"{url}{BACKEND_HEALTH_ENDPOINT}",
                timeout=2,
            )

            if response.status_code == 200:
                log_info("Backend is ready.")
                return

        except requests.RequestException:
            pass

        time.sleep(BACKEND_RETRY_INTERVAL)

    raise RuntimeError(
        f"Backend failed to start within {timeout} seconds."
    )


def find_flutter_executable() -> str:
    """
    Locate the Flutter executable.
    """

    if FLUTTER_EXECUTABLE is not None:

        flutter = Path(FLUTTER_EXECUTABLE)

        if not flutter.is_file():
            raise RuntimeError(
                f"Flutter executable not found:\n{flutter}"
            )

        return str(flutter)

    flutter = (
        shutil.which("flutter")
        or shutil.which("flutter.bat")
    )

    if flutter is None:
        raise RuntimeError(
            "\nFlutter could not be found.\n\n"
            "Either:\n"
            "  1. Add Flutter to your PATH\n"
            "  2. Set FLUTTER_EXECUTABLE\n"
        )

    return flutter


def get_frontend_command(mode: RunMode) -> list[str]:
    """Return the command used to launch the frontend."""

    if mode == RunMode.RELEASE:
        return [str(FRONTEND_EXECUTABLE)]

    flutter = find_flutter_executable()

    return [
        "cmd",
        "/c",
        flutter,
        "run",
        "-d",
        FLUTTER_DEVICE,
    ]


def start_frontend(mode: RunMode) -> subprocess.Popen:
    """
    Start the frontend application.
    """

    if mode == RunMode.DEVELOPMENT:
        command = get_frontend_command(mode)
        cwd = FRONTEND_PATH
        log_info("Starting Flutter frontend...")
    else:
        command = get_frontend_command(mode)
        cwd = PROJECT_ROOT
        log_info("Starting packaged frontend...")

    process = subprocess.Popen(
        command,
        cwd=cwd,
    )

    log_info(f"Frontend started (PID {process.pid}).")

    return process


def monitor_frontend(frontend_process: subprocess.Popen) -> None:
    """
    Wait until the frontend exits.
    """

    log_info("Monitoring frontend...")

    try:
        frontend_process.wait()
    except KeyboardInterrupt:
        log_info("Launcher interrupted.")

    log_info("Frontend has closed.")


def shutdown_frontend(frontend_process: subprocess.Popen | None) -> None:
    """
    Shut down the frontend if it is still running.
    """

    if frontend_process is None:
        return

    if frontend_process.poll() is not None:
        return

    log_info("Stopping frontend...")

    frontend_process.terminate()

    try:
        frontend_process.wait(timeout=5)

    except subprocess.TimeoutExpired:
        log_info("Frontend did not exit in time. Killing process...")
        frontend_process.kill()
        frontend_process.wait()

    log_info("Frontend stopped.")


def shutdown_backend(backend_process: subprocess.Popen | None) -> None:
    """
    Shut down the backend if it is still running.
    """

    if backend_process is None:
        return

    if backend_process.poll() is not None:
        return

    log_info("Stopping backend...")

    backend_process.terminate()

    try:
        backend_process.wait(timeout=5)

    except subprocess.TimeoutExpired:
        log_info("Backend did not exit in time. Killing process...")
        backend_process.kill()
        backend_process.wait()

    log_info("Backend stopped.")


def cleanup() -> None:
    """
    Perform launcher cleanup.
    """

    log_info("Cleanup complete.")


def main() -> None:
    """
    Launcher entry point.
    """

    backend_process: subprocess.Popen | None = None
    frontend_process: subprocess.Popen | None = None

    try:
        mode = detect_mode()

        log_info(f"Launcher Mode: {mode.name}")

        backend_process = start_backend(mode)

        wait_for_backend()

        frontend_process = start_frontend(mode)

        monitor_frontend(frontend_process)

    except KeyboardInterrupt:
        log_info("Launcher interrupted by user.")

    finally:
        shutdown_frontend(frontend_process)
        shutdown_backend(backend_process)
        cleanup()


if __name__ == "__main__":
    main()
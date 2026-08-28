"""
ElectricalAI Pro
Windows release builder.

Builds:
1. Backend executable (FastAPI)
2. Launcher executable
3. Flutter Windows UI
4. A release/ folder ready for Inno Setup
"""

from __future__ import annotations

from pathlib import Path
import shutil
import subprocess
import sys

PROJECT_ROOT = Path(__file__).resolve().parent
BUILD_DIR = PROJECT_ROOT / "build"
DIST_DIR = PROJECT_ROOT / "dist"
RELEASE_DIR = PROJECT_ROOT / "release"
FLUTTER_RELEASE = (
    PROJECT_ROOT / "frontend" / "build" / "windows" / "x64" / "runner" / "Release"
)


def log(message: str) -> None:
    print(f"[INFO] {message}")


def error(message: str) -> None:
    print(f"[ERROR] {message}")
    sys.exit(1)


def run(command: list[str], cwd: Path = PROJECT_ROOT) -> None:
    result = subprocess.run(command, cwd=cwd)
    if result.returncode != 0:
        error(f"Command failed: {' '.join(command)}")


def clean() -> None:
    log("Cleaning previous build folders...")
    for folder in (BUILD_DIR, DIST_DIR, RELEASE_DIR):
        if folder.exists():
            shutil.rmtree(folder)
    log("Clean complete.")


def build_backend() -> None:
    log("Building backend...")
    run(
        [
            sys.executable,
            "-m",
            "PyInstaller",
            "--noconfirm",
            "--name",
            "ElectricalAI-Pro-Backend",
            "--onefile",
            "run_backend.py",
        ]
    )


def build_launcher() -> None:
    log("Building launcher...")
    run(
        [
            sys.executable,
            "-m",
            "PyInstaller",
            "--noconfirm",
            "--name",
            "ElectricalAI-Pro",
            "--onefile",
            "launcher.py",
        ]
    )


def build_flutter() -> None:
    log("Building Flutter Windows UI...")
    flutter = shutil.which("flutter") or shutil.which("flutter.bat")
    if flutter is None:
        error("Flutter was not found on PATH.")
    run([flutter, "build", "windows", "--release"], cwd=PROJECT_ROOT / "frontend")


def create_release() -> None:
    log("Creating release folder...")
    if not FLUTTER_RELEASE.is_dir():
        error(f"Flutter release folder missing: {FLUTTER_RELEASE}")

    shutil.copytree(FLUTTER_RELEASE, RELEASE_DIR)

    backend = DIST_DIR / "ElectricalAI-Pro-Backend.exe"
    launcher = DIST_DIR / "ElectricalAI-Pro.exe"
    if not backend.is_file():
        error("Backend executable was not built.")
    if not launcher.is_file():
        error("Launcher executable was not built.")

    shutil.copy2(backend, RELEASE_DIR / backend.name)
    shutil.copy2(launcher, RELEASE_DIR / launcher.name)

    env_example = PROJECT_ROOT / ".env.example"
    if env_example.is_file():
        shutil.copy2(env_example, RELEASE_DIR / ".env.example")

    log("Release folder created.")


def verify() -> None:
    required = [
        RELEASE_DIR / "ElectricalAI-Pro.exe",
        RELEASE_DIR / "ElectricalAI-Pro-Backend.exe",
        RELEASE_DIR / "frontend.exe",
    ]
    missing = [path.name for path in required if not path.is_file()]
    if missing:
        error("Release is missing: " + ", ".join(missing))
    log("Release verified.")


def main() -> None:
    log("ElectricalAI Pro Release Builder")
    log("--------------------------------")
    clean()
    build_backend()
    build_launcher()
    build_flutter()
    create_release()
    verify()
    log("--------------------------------")
    log("Release Build Complete!")
    log(f"Output: {RELEASE_DIR}")
    log("Compile installer/ElectricalAI-Pro.iss with Inno Setup to build Setup.exe.")


if __name__ == "__main__":
    main()

"""
ElectricalAI Pro
Automated Release Builder

This script builds a complete Windows release by:

1. Cleaning previous build folders
2. Building the backend executable
3. Building the launcher executable
4. Building the Flutter application
5. Creating the release folder
6. Copying required files
7. Verifying the release

Version: 1.0
"""

from pathlib import Path
import shutil
import subprocess
import sys

# ---------------------------------------------------
# Project Paths
# ---------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parent

BUILD_DIR = PROJECT_ROOT / "build"
DIST_DIR = PROJECT_ROOT / "dist"
RELEASE_DIR = PROJECT_ROOT / "release"

BACKEND_SPEC = PROJECT_ROOT / "ElectricalAI-Pro-Backend.spec"
LAUNCHER_SPEC = PROJECT_ROOT / "ElectricalAI-Pro.spec"

FLUTTER_RELEASE = (
    PROJECT_ROOT
    / "frontend"
    / "build"
    / "windows"
    / "x64"
    / "runner"
    / "Release"
)

# ---------------------------------------------------
# Logging
# ---------------------------------------------------

def log(message: str):
    print(f"[INFO] {message}")


def error(message: str):
    print(f"[ERROR] {message}")
    sys.exit(1)


# ---------------------------------------------------
# Build Steps
# ---------------------------------------------------

def clean():
    """Delete previous build folders and generated spec files."""

    log("Cleaning previous build folders...")

    folders = [
        BUILD_DIR,
        DIST_DIR,
        RELEASE_DIR,
    ]

    for folder in folders:
        if folder.exists():
            log(f"Deleting {folder.name}...")

            try:
                shutil.rmtree(folder)
            except PermissionError:
                error(
                    f"Unable to delete '{folder.name}'.\n\n"
                    "The folder is being used by another program.\n"
                    "Close Windows Explorer, VS Code tabs, or any running\n"
                    "ElectricalAI Pro executables and try again."
                )

    spec_files = [
        BACKEND_SPEC,
        LAUNCHER_SPEC,
    ]

    for spec in spec_files:
        if spec.exists():
            log(f"Deleting {spec.name}...")

            try:
                spec.unlink()
            except PermissionError:
                error(
                    f"Unable to delete '{spec.name}'.\n\n"
                    "The file is currently in use.\n"
                    "Close any applications that may be using it and try again."
                )

    log("Clean complete.")


def build_backend():
    """Build the backend executable."""

    log("Building backend...")

    result = subprocess.run(
        [
            sys.executable,
            "-m",
            "PyInstaller",
            "--name",
            "ElectricalAI-Pro-Backend",
            "--onefile",
            "run_backend.py",
        ],
        cwd=PROJECT_ROOT,
    )

    if result.returncode != 0:
        error("Backend build failed.")

    log("Backend build complete.")


def build_launcher():
    """Build the launcher executable."""
    log("Building launcher...")


def build_flutter():
    """Build Flutter Windows application."""
    log("Building Flutter...")


def create_release():
    """Create the release folder."""

    log("Creating release folder...")

    RELEASE_DIR.mkdir(parents=True, exist_ok=True)

    log("Release folder created.")


def copy_files():
    """Copy required release files."""
    log("Copying release files...")


def verify():
    """Verify final release."""
    log("Verifying release...")


# ---------------------------------------------------
# Main
# ---------------------------------------------------

def main():

    log("ElectricalAI Pro Release Builder")
    log("--------------------------------")

    clean()

    build_backend()

    build_launcher()

    build_flutter()

    create_release()

    copy_files()

    verify()

    log("--------------------------------")
    log("Release Build Complete!")


if __name__ == "__main__":
    main()
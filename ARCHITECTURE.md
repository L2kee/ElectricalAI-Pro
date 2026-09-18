# ElectricalAI Pro Architecture

## Philosophy

Modular code. One responsibility per file. Calculators that electricians
use in the field must run without a network or a Python process.

## Layout

```
ElectricalAI-Pro/
  launcher.py              Start backend + Flutter (dev or release)
  run_backend.py           FastAPI entrypoint
  backend/
    api/server.py          HTTP routes (AI + calculator API)
    ai/                    NVIDIA chat client and prompts
    data/tables.py         Shared electrical reference data
    models/                Pydantic request bodies
    services/              Calculator and AI services
    tests/
  frontend/
    lib/calculators/       Same math, in Dart, used by the UI
    lib/screens/
    lib/widgets/
    lib/services/          AI and material-list HTTP client
  docs/
  installer/               Inno Setup script (binaries are not committed)
```

## What runs where

- **Flutter** owns the desktop UI and all deterministic calculators.
  Voltage drop, box fill, conduit fill, ampacity, circuit load, and Ohm's
  law are computed on-device so the tools work offline.
- **FastAPI** exposes the same calculator math over HTTP for Swagger,
  tests, and future mobile/web clients, and it owns AI chat plus material
  lists (NVIDIA Build API).
- **launcher.py** starts uvicorn, waits on `/health`, then starts Flutter.
  In a packaged Windows build it starts `ElectricalAI-Pro-Backend.exe`
  and `frontend.exe`.

The frontend must not invent electrical math that the backend does not
also implement. Keep `backend/data/tables.py` and
`frontend/lib/calculators/tables.dart` in sync.

## Coding standards

- PEP 8 in Python, `flutter analyze` in Dart
- Raise `CalculatorError` (mapped to HTTP 400) instead of returning
  `{"error": ...}` with status 200
- Small functions, no duplicated calculator screens
- Never commit `.env` or installer binaries

## Trust

Every calculator and the AI assistant is a planning aid. Results must be
verified against the applicable code, manufacturer data, and the AHJ.
Do not reproduce copyrighted NEC text verbatim.

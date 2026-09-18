# ElectricalAI Pro Architecture

See the root `ARCHITECTURE.md` for the current layout.

Version 1.0.1:

- Deterministic calculators run in Flutter (offline) and are mirrored in
  FastAPI for the API and tests.
- AI chat and material lists require the local backend and `NVIDIA_API_KEY`.
- Windows packaging must ship the launcher, backend exe, and Flutter UI
  together. The installer must not ship the UI alone.

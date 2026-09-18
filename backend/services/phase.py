"""Shared single-phase/three-phase parsing for calculators."""

from __future__ import annotations

from backend.services.errors import CalculatorError

_SINGLE_ALIASES = {"single", "1", "1ph", "single-phase"}
_THREE_ALIASES = {"three", "3", "3ph", "three-phase"}


def normalize_phase(phase: str) -> str:
    """Return 'single' or 'three' for a phase string, or raise CalculatorError."""
    kind = phase.strip().lower()
    if kind in _SINGLE_ALIASES:
        return "single"
    if kind in _THREE_ALIASES:
        return "three"
    raise CalculatorError("Phase must be single or three.")

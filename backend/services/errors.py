"""Typed calculator errors mapped to HTTP 400 by the API."""

from __future__ import annotations


class CalculatorError(ValueError):
    """User-facing input or lookup error for a calculator."""

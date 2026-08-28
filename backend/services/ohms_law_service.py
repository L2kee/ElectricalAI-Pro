"""Ohm's Law: solve for V, I, or R given any two values."""

from __future__ import annotations

from backend.services.errors import CalculatorError


class OhmsLawService:
    def calculate(self, voltage=None, current=None, resistance=None):
        provided = sum(value is not None for value in (voltage, current, resistance))
        if provided != 2:
            raise CalculatorError("Provide exactly two of voltage, current, and resistance.")

        for name, value in (
            ("voltage", voltage),
            ("current", current),
            ("resistance", resistance),
        ):
            if value is not None and value <= 0:
                raise CalculatorError(f"{name.capitalize()} must be greater than zero.")

        if voltage is None:
            return {"voltage": round(current * resistance, 4), "unit": "V"}
        if current is None:
            return {"current": round(voltage / resistance, 4), "unit": "A"}
        return {"resistance": round(voltage / current, 4), "unit": "Ω"}

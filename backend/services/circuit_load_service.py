"""Circuit load: P = V × I, with optional continuous 125% and breaker sizing."""

from __future__ import annotations

from backend.data.tables import STANDARD_BREAKERS_AMPS
from backend.services.errors import CalculatorError


def _next_standard_breaker(amps: float) -> int | None:
    for size in STANDARD_BREAKERS_AMPS:
        if size >= amps:
            return size
    return None


class CircuitLoadService:
    def calculate(
        self,
        power=None,
        voltage=None,
        current=None,
        continuous: bool = False,
    ):
        provided = sum(value is not None for value in (power, voltage, current))
        if provided != 2:
            raise CalculatorError("Provide exactly two of power, voltage, and current.")

        for name, value in (("power", power), ("voltage", voltage), ("current", current)):
            if value is not None and value <= 0:
                raise CalculatorError(f"{name.capitalize()} must be greater than zero.")

        if power is None:
            power = voltage * current
            solved = "power"
        elif voltage is None:
            voltage = power / current
            solved = "voltage"
        else:
            current = power / voltage
            solved = "current"

        design_current = current * 1.25 if continuous else current
        breaker = _next_standard_breaker(design_current)

        return {
            "power": round(power, 2),
            "voltage": round(voltage, 2),
            "current": round(current, 2),
            "solved": solved,
            "continuous": continuous,
            "design_current": round(design_current, 2),
            "suggested_breaker_amps": breaker,
            "notes": (
                "Continuous loads are calculated at 125% of current before selecting a breaker. "
                "This is a planning aid, not a panel schedule."
            ),
        }

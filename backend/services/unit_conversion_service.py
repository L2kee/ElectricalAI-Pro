"""Unit conversion for length, power, and temperature."""

from __future__ import annotations

from backend.data.tables import LENGTH_TO_METERS, POWER_TO_WATTS
from backend.services.errors import CalculatorError
from backend.services.rounding import round_half_up

_TEMPERATURE_UNITS = {"C", "F"}
_FACTOR_TABLES = {"length": LENGTH_TO_METERS, "power": POWER_TO_WATTS}


def _lookup_unit(table: dict[str, float], unit: str) -> tuple[str, float] | None:
    """Case-insensitive, whitespace-tolerant lookup that returns the table's canonical key."""
    trimmed = unit.strip()
    if trimmed in table:
        return trimmed, table[trimmed]
    lowered = trimmed.lower()
    for key, factor in table.items():
        if key.lower() == lowered:
            return key, factor
    return None


class UnitConversionService:
    def convert(
        self,
        category: str,
        from_unit: str,
        to_unit: str,
        value: float,
    ):
        cat = category.strip().lower()

        if cat == "temperature":
            return self._convert_temperature(from_unit, to_unit, value)

        table = _FACTOR_TABLES.get(cat)
        if table is None:
            raise CalculatorError("Category must be length, power, or temperature.")

        from_match = _lookup_unit(table, from_unit)
        to_match = _lookup_unit(table, to_unit)
        if from_match is None or to_match is None:
            supported = ", ".join(table.keys())
            raise CalculatorError(f"Unsupported {cat} unit. Use one of {supported}.")

        from_key, from_factor = from_match
        to_key, to_factor = to_match
        result = value * from_factor / to_factor

        return {
            "category": cat,
            "from_unit": from_key,
            "to_unit": to_key,
            "value": value,
            "result": round_half_up(result, 4),
        }

    def _convert_temperature(self, from_unit: str, to_unit: str, value: float):
        f = from_unit.strip().upper()
        t = to_unit.strip().upper()
        if f not in _TEMPERATURE_UNITS or t not in _TEMPERATURE_UNITS:
            raise CalculatorError("Temperature unit must be C or F.")

        if f == t:
            result = value
        elif f == "C" and t == "F":
            result = value * 9.0 / 5.0 + 32.0
        else:
            result = (value - 32.0) * 5.0 / 9.0

        return {
            "category": "temperature",
            "from_unit": f,
            "to_unit": t,
            "value": value,
            "result": round_half_up(result, 2),
        }

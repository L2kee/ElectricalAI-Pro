"""Voltage drop from wire size, material, length, load, and system type."""

from __future__ import annotations

from backend.data.tables import ALUMINUM_RESISTANCE_MULTIPLIER, COPPER_OHMS_PER_KFT_75C
from backend.services.errors import CalculatorError


class VoltageDropService:
    def calculate(
        self,
        current: float,
        wire_size: str,
        length_ft: float,
        material: str = "copper",
        voltage: float = 120,
        phase: str = "single",
    ):
        if current <= 0:
            raise CalculatorError("Current must be greater than zero.")
        if length_ft <= 0:
            raise CalculatorError("One-way circuit length must be greater than zero.")
        if voltage <= 0:
            raise CalculatorError("System voltage must be greater than zero.")

        ohms_per_kft = COPPER_OHMS_PER_KFT_75C.get(wire_size)
        if ohms_per_kft is None:
            raise CalculatorError(f"Unsupported wire size: {wire_size}")

        metal = material.strip().lower()
        if metal == "aluminum":
            ohms_per_kft *= ALUMINUM_RESISTANCE_MULTIPLIER
        elif metal != "copper":
            raise CalculatorError("Material must be copper or aluminum.")

        kind = phase.strip().lower()
        if kind in {"single", "1", "1ph", "single-phase"}:
            multiplier = 2.0
            phase_label = "single-phase"
        elif kind in {"three", "3", "3ph", "three-phase"}:
            multiplier = 1.732
            phase_label = "three-phase"
        else:
            raise CalculatorError("Phase must be single or three.")

        voltage_drop = current * ohms_per_kft * (length_ft / 1000.0) * multiplier
        percent = (voltage_drop / voltage) * 100.0

        return {
            "voltage_drop": round(voltage_drop, 2),
            "percent_drop": round(percent, 2),
            "within_3_percent": percent <= 3.0,
            "within_5_percent": percent <= 5.0,
            "wire_size": wire_size,
            "material": metal,
            "phase": phase_label,
            "system_voltage": voltage,
            "notes": (
                "Uses approximate 75°C conductor resistance. "
                "3% is a common branch-circuit target and 5% a common feeder-plus-branch target; "
                "confirm against the applicable code and the AHJ."
            ),
        }

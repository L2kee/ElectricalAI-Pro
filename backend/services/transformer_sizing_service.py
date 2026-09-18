"""Transformer primary/secondary full-load amperes from kVA rating."""

from __future__ import annotations

from backend.services.errors import CalculatorError
from backend.services.phase import normalize_phase
from backend.services.rounding import round_half_up

THREE_PHASE_FACTOR = 1.732


class TransformerSizingService:
    def calculate(
        self,
        kva: float,
        primary_voltage: float,
        secondary_voltage: float,
        phase: str = "three",
    ):
        if kva <= 0:
            raise CalculatorError("kVA must be greater than zero.")
        if primary_voltage <= 0 or secondary_voltage <= 0:
            raise CalculatorError("Primary and secondary voltage must be greater than zero.")

        kind = normalize_phase(phase)
        phase_label = "single-phase" if kind == "single" else "three-phase"
        factor = 1.0 if kind == "single" else THREE_PHASE_FACTOR
        divisor_primary = primary_voltage * factor
        divisor_secondary = secondary_voltage * factor

        va = kva * 1000.0

        return {
            "kva": kva,
            "phase": phase_label,
            "primary_voltage": primary_voltage,
            "secondary_voltage": secondary_voltage,
            "primary_fla": round_half_up(va / divisor_primary, 2),
            "secondary_fla": round_half_up(va / divisor_secondary, 2),
            "units": "A",
            "notes": (
                "Full-load amperes at the transformer's rated kVA, not a measured load. "
                "Overcurrent protection and conductor sizing must still be selected per the "
                "applicable code (transformer and feeder/branch protection rules) and the AHJ."
            ),
        }

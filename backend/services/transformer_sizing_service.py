"""Transformer primary/secondary full-load amperes from kVA rating."""

from __future__ import annotations

from backend.services.errors import CalculatorError

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

        kind = phase.strip().lower()
        if kind in {"single", "1", "1ph", "single-phase"}:
            divisor_primary = primary_voltage
            divisor_secondary = secondary_voltage
            phase_label = "single-phase"
        elif kind in {"three", "3", "3ph", "three-phase"}:
            divisor_primary = primary_voltage * THREE_PHASE_FACTOR
            divisor_secondary = secondary_voltage * THREE_PHASE_FACTOR
            phase_label = "three-phase"
        else:
            raise CalculatorError("Phase must be single or three.")

        va = kva * 1000.0

        return {
            "kva": kva,
            "phase": phase_label,
            "primary_voltage": primary_voltage,
            "secondary_voltage": secondary_voltage,
            "primary_fla": round(va / divisor_primary, 2),
            "secondary_fla": round(va / divisor_secondary, 2),
            "units": "A",
            "notes": (
                "Full-load amperes at the transformer's rated kVA, not a measured load. "
                "Overcurrent protection and conductor sizing must still be selected per the "
                "applicable code (transformer and feeder/branch protection rules) and the AHJ."
            ),
        }

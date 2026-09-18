"""Motor full-load current lookup (single- and three-phase)."""

from __future__ import annotations

from backend.data.tables import MOTOR_FLC_SINGLE_PHASE, MOTOR_FLC_THREE_PHASE
from backend.services.errors import CalculatorError


class MotorFlcService:
    def calculate(
        self,
        horsepower: str,
        voltage: str,
        phase: str = "three",
    ):
        kind = phase.strip().lower()
        if kind in {"single", "1", "1ph", "single-phase"}:
            table = MOTOR_FLC_SINGLE_PHASE
            phase_label = "single-phase"
        elif kind in {"three", "3", "3ph", "three-phase"}:
            table = MOTOR_FLC_THREE_PHASE
            phase_label = "three-phase"
        else:
            raise CalculatorError("Phase must be single or three.")

        hp = horsepower.strip()
        row = table.get(hp)
        if row is None:
            raise CalculatorError(f"Unsupported {phase_label} horsepower: {horsepower}")

        volts = voltage.strip()
        flc = row.get(volts)
        if flc is None:
            supported = ", ".join(row.keys())
            raise CalculatorError(
                f"Unsupported voltage for {hp} HP {phase_label}: {voltage}. Use one of {supported}."
            )

        return {
            "horsepower": hp,
            "voltage": volts,
            "phase": phase_label,
            "full_load_current": flc,
            "units": "A",
            "min_conductor_ampacity_amps": round(flc * 1.25, 2),
            "notes": (
                "Table lookup, not a nameplate reading; use the motor nameplate FLA when it is available. "
                "Conductor ampacity shown is 125% of FLC for a single continuous-duty motor. Branch-circuit "
                "short-circuit/ground-fault protection and overload sizing must still be selected per the "
                "applicable code, the motor's service factor, and its nameplate."
            ),
        }

"""Voltage drop across every standard wire size, for picking the smallest that fits."""

from __future__ import annotations

from backend.data.tables import COPPER_OHMS_PER_KFT_75C
from backend.services.voltage_drop_service import VoltageDropService

# Smallest to largest conductor, so the first match is the smallest that qualifies.
_WIRE_SIZE_ORDER = list(COPPER_OHMS_PER_KFT_75C.keys())


class VoltageDropComparisonService:
    def __init__(self, voltage_drop_service: VoltageDropService | None = None):
        self._voltage_drop_service = voltage_drop_service or VoltageDropService()

    def compare(
        self,
        current: float,
        length_ft: float,
        material: str = "copper",
        voltage: float = 120,
        phase: str = "single",
    ):
        rows = [
            self._voltage_drop_service.calculate(
                current=current,
                wire_size=wire_size,
                length_ft=length_ft,
                material=material,
                voltage=voltage,
                phase=phase,
            )
            for wire_size in _WIRE_SIZE_ORDER
        ]

        results = [
            {
                "wire_size": row["wire_size"],
                "voltage_drop": row["voltage_drop"],
                "percent_drop": row["percent_drop"],
                "within_3_percent": row["within_3_percent"],
                "within_5_percent": row["within_5_percent"],
            }
            for row in rows
        ]

        smallest_within_3 = next((r["wire_size"] for r in results if r["within_3_percent"]), None)
        smallest_within_5 = next((r["wire_size"] for r in results if r["within_5_percent"]), None)

        return {
            "material": rows[0]["material"],
            "phase": rows[0]["phase"],
            "system_voltage": rows[0]["system_voltage"],
            "results": results,
            "smallest_size_within_3_percent": smallest_within_3,
            "smallest_size_within_5_percent": smallest_within_5,
            "notes": (
                "Uses approximate 75°C conductor resistance for every standard wire size. "
                "3% is a common branch-circuit target and 5% a common feeder-plus-branch target; "
                "confirm against the applicable code and the AHJ."
            ),
        }

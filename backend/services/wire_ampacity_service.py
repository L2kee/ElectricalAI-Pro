"""Allowable ampacity lookup with small-conductor overcurrent notes."""

from __future__ import annotations

from backend.data.tables import ALUMINUM_AMPACITY, COPPER_AMPACITY, SMALL_CONDUCTOR_OCPD
from backend.services.errors import CalculatorError


class WireAmpacityService:
    def calculate(
        self,
        wire_size: str,
        temperature_rating: str,
        material: str = "copper",
    ):
        metal = material.strip().lower()
        table = COPPER_AMPACITY if metal == "copper" else ALUMINUM_AMPACITY if metal == "aluminum" else None
        if table is None:
            raise CalculatorError("Material must be copper or aluminum.")

        if wire_size not in table:
            raise CalculatorError(f"Unsupported {metal} wire size: {wire_size}")

        rating = str(temperature_rating).replace("°C", "").replace("C", "").strip()
        if rating not in table[wire_size]:
            raise CalculatorError("Temperature rating must be 60, 75, or 90.")

        ampacity = table[wire_size][rating]
        ocpd = SMALL_CONDUCTOR_OCPD.get((metal, wire_size))

        notes = [
            "Lookup is for 3 or fewer current-carrying conductors in a raceway or cable, 30°C ambient.",
            "Apply ambient and bundling adjustments before selecting overcurrent protection.",
        ]
        if ocpd is not None:
            notes.append(
                f"Small-conductor overcurrent is commonly limited to {ocpd} A for {metal} {wire_size} "
                "on typical branch circuits unless an exception applies."
            )

        return {
            "wire_size": wire_size,
            "material": metal,
            "temperature_rating": rating,
            "ampacity": ampacity,
            "units": "A",
            "typical_branch_ocpd_amps": ocpd,
            "notes": " ".join(notes),
        }

"""
ElectricalAI Pro

Wire Ampacity Service
"""

from backend.data.ampacity_table import AMPACITY_TABLE


class WireAmpacityService:

    def calculate(
        self,
        wire_size: str,
        temperature_rating: str,
    ):

        if wire_size not in AMPACITY_TABLE:
            return {
                "error": f"Unsupported wire size: {wire_size}"
            }

        if temperature_rating not in AMPACITY_TABLE[wire_size]:
            return {
                "error": f"Unsupported temperature rating: {temperature_rating}"
            }

        ampacity = AMPACITY_TABLE[wire_size][temperature_rating]

        return {
            "wire_size": wire_size,
            "temperature_rating": temperature_rating,
            "ampacity": ampacity,
            "units": "Amps"
        }
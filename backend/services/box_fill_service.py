"""
ElectricalAI Pro

Box Fill Service
"""


class BoxFillService:

    def calculate(
        self,
        box_volume: float,
        conductor_count: int,
        conductor_allowance: float,
    ):

        required_volume = (
            conductor_count * conductor_allowance
        )

        remaining_volume = (
            box_volume - required_volume
        )

        return {
            "required_volume": round(required_volume, 2),
            "remaining_volume": round(remaining_volume, 2),
            "box_is_large_enough": remaining_volume >= 0,
        }
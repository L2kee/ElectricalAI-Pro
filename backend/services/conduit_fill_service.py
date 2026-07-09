"""
ElectricalAI Pro

Conduit Fill Service
"""


class ConduitFillService:

    def calculate(
        self,
        conduit_area: float,
        wire_area: float,
        wire_count: int,
    ):

        total_wire_area = wire_area * wire_count

        percent_fill = (total_wire_area / conduit_area) * 100

        return {
            "total_wire_area": round(total_wire_area, 4),
            "percent_fill": round(percent_fill, 2),
        }
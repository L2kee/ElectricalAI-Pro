"""Conduit fill from raceway type/size and THHN conductor count."""

from __future__ import annotations

from backend.data.tables import CONDUIT_AREA_SQIN, THHN_AREA_SQIN
from backend.services.errors import CalculatorError


class ConduitFillService:
    def calculate(
        self,
        conduit_type: str,
        trade_size: str,
        wire_size: str,
        wire_count: int,
    ):
        if wire_count <= 0:
            raise CalculatorError("Wire count must be greater than zero.")

        raceway = conduit_type.strip().upper()
        if raceway not in CONDUIT_AREA_SQIN:
            raise CalculatorError("Conduit type must be EMT, PVC-40, or RMC.")

        size = trade_size.strip()
        conduit_area = CONDUIT_AREA_SQIN[raceway].get(size)
        if conduit_area is None:
            raise CalculatorError(f"Unsupported {raceway} trade size: {trade_size}")

        wire_area = THHN_AREA_SQIN.get(wire_size)
        if wire_area is None:
            raise CalculatorError(f"Unsupported THHN wire size: {wire_size}")

        if wire_count == 1:
            limit = 53.0
            limit_note = "1 conductor: 53% fill"
        elif wire_count == 2:
            limit = 31.0
            limit_note = "2 conductors: 31% fill"
        else:
            limit = 40.0
            limit_note = "3 or more conductors: 40% fill"

        total_wire_area = wire_area * wire_count
        percent_fill = (total_wire_area / conduit_area) * 100.0

        return {
            "conduit_type": raceway,
            "trade_size": size,
            "wire_size": wire_size,
            "wire_count": wire_count,
            "conduit_area": round(conduit_area, 4),
            "wire_area": round(wire_area, 4),
            "total_wire_area": round(total_wire_area, 4),
            "percent_fill": round(percent_fill, 2),
            "fill_limit_percent": limit,
            "within_limit": percent_fill <= limit,
            "notes": (
                f"{limit_note}. Uses approximate THHN/THWN areas. "
                "Nipples 24 in. or less may use 60%. Confirm Chapter 9 and the AHJ."
            ),
        }

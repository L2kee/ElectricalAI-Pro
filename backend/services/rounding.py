"""Round-half-up helper so backend results match the Dart on-device math.

Python's builtin round() uses round-half-to-even, while Dart's
double.toStringAsFixed rounds exact ties away from zero. For non-negative
amperage/voltage values used across the calculators, this keeps both
platforms returning the same number for the same input.
"""

from __future__ import annotations

from decimal import ROUND_HALF_UP, Decimal


def round_half_up(value: float, decimals: int = 2) -> float:
    quant = Decimal(1).scaleb(-decimals)
    return float(Decimal(str(value)).quantize(quant, rounding=ROUND_HALF_UP))

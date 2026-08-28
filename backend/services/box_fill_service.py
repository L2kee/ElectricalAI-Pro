"""Box-fill planning: conductors, devices, clamps, and equipment grounds."""

from __future__ import annotations

from backend.data.tables import BOX_FILL_ALLOWANCE_CUIN
from backend.services.errors import CalculatorError


class BoxFillService:
    def calculate(
        self,
        box_volume: float,
        conductor_size: str,
        conductor_count: int,
        device_count: int = 0,
        clamp_count: int = 0,
        equipment_ground_count: int = 0,
    ):
        if box_volume <= 0:
            raise CalculatorError("Box volume must be greater than zero.")
        if conductor_count < 0 or device_count < 0 or clamp_count < 0 or equipment_ground_count < 0:
            raise CalculatorError("Counts cannot be negative.")

        allowance = BOX_FILL_ALLOWANCE_CUIN.get(conductor_size)
        if allowance is None:
            raise CalculatorError(f"Unsupported conductor size for box fill: {conductor_size}")

        # Device yokes count as two conductors of the largest size connected to the device.
        device_volume = device_count * 2 * allowance
        # Internal cable clamps, if any, count once (not per clamp).
        clamp_volume = allowance if clamp_count > 0 else 0.0
        # Equipment grounds count once, based on the largest ground present.
        ground_volume = allowance if equipment_ground_count > 0 else 0.0
        conductor_volume = conductor_count * allowance

        required = conductor_volume + device_volume + clamp_volume + ground_volume
        remaining = box_volume - required

        return {
            "conductor_size": conductor_size,
            "allowance_cu_in": allowance,
            "conductor_volume": round(conductor_volume, 2),
            "device_volume": round(device_volume, 2),
            "clamp_volume": round(clamp_volume, 2),
            "ground_volume": round(ground_volume, 2),
            "required_volume": round(required, 2),
            "remaining_volume": round(remaining, 2),
            "box_is_large_enough": remaining >= 0,
            "notes": (
                "Each device yoke counts as two conductors. Internal clamps count once. "
                "Equipment grounding conductors count once at the largest ground size. "
                "Confirm against 314.16 and the box marking."
            ),
        }

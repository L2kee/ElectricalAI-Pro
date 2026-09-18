"""Static NEC-style quick-reference tables. Not a calculator: no inputs, no validation."""

from __future__ import annotations

from backend.data.tables import (
    NEC_BOX_VOLUMES_CUIN,
    NEC_CONDUIT_BEND_RADIUS_IN,
    STANDARD_BREAKERS_AMPS,
)


class NecReferenceService:
    def get_reference(self):
        return {
            "standard_breaker_fuse_amps": list(STANDARD_BREAKERS_AMPS),
            "box_volumes": [
                {"box_type": box_type, "volume_cuin": volume}
                for box_type, volume in NEC_BOX_VOLUMES_CUIN.items()
            ],
            "conduit_bend_radius": [
                {
                    "trade_size": trade_size,
                    "one_shot_in": radii["one_shot"],
                    "other_bends_in": radii["other_bends"],
                }
                for trade_size, radii in NEC_CONDUIT_BEND_RADIUS_IN.items()
            ],
            "notes": (
                "Reference values only, not a reproduction of the NEC. Box volumes follow "
                "Table 314.16(A)-style entries; bend radii follow Chapter 9 Table 2-style "
                "entries. Always confirm against the applicable code, manufacturer "
                "instructions, and the AHJ."
            ),
        }

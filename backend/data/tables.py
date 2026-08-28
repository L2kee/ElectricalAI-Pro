"""
ElectricalAI Pro — reference data used by the calculators.

These values follow common industry practice used in field calculators
(copper/aluminum DC resistance at 75°C, typical raceway internal areas,
THHN approximate cross-sections, 310.16-style ampacity, 314.16(B)-style
box-fill allowances). They are planning aids, not a reproduction of the
NEC and not a substitute for the codebook, manufacturer data, or the AHJ.
"""

from __future__ import annotations

# Ohms per 1,000 ft at 75°C (approximate). Used for voltage drop.
COPPER_OHMS_PER_KFT_75C: dict[str, float] = {
    "14 AWG": 3.07,
    "12 AWG": 1.93,
    "10 AWG": 1.21,
    "8 AWG": 0.764,
    "6 AWG": 0.491,
    "4 AWG": 0.308,
    "3 AWG": 0.245,
    "2 AWG": 0.194,
    "1 AWG": 0.154,
    "1/0 AWG": 0.122,
    "2/0 AWG": 0.0967,
    "3/0 AWG": 0.0766,
    "4/0 AWG": 0.0608,
    "250 kcmil": 0.0515,
    "300 kcmil": 0.0429,
    "350 kcmil": 0.0367,
    "400 kcmil": 0.0321,
    "500 kcmil": 0.0258,
}

# Aluminum ≈ copper × 1.64 at the same temperature.
ALUMINUM_RESISTANCE_MULTIPLIER = 1.64

# 60/75/90 °C columns, copper, 3 or fewer current-carrying conductors.
COPPER_AMPACITY: dict[str, dict[str, int]] = {
    "14 AWG": {"60": 15, "75": 20, "90": 25},
    "12 AWG": {"60": 20, "75": 25, "90": 30},
    "10 AWG": {"60": 30, "75": 35, "90": 40},
    "8 AWG": {"60": 40, "75": 50, "90": 55},
    "6 AWG": {"60": 55, "75": 65, "90": 75},
    "4 AWG": {"60": 70, "75": 85, "90": 95},
    "3 AWG": {"60": 85, "75": 100, "90": 110},
    "2 AWG": {"60": 95, "75": 115, "90": 130},
    "1 AWG": {"60": 110, "75": 130, "90": 150},
    "1/0 AWG": {"60": 125, "75": 150, "90": 170},
    "2/0 AWG": {"60": 145, "75": 175, "90": 195},
    "3/0 AWG": {"60": 165, "75": 200, "90": 225},
    "4/0 AWG": {"60": 195, "75": 230, "90": 260},
}

ALUMINUM_AMPACITY: dict[str, dict[str, int]] = {
    "12 AWG": {"60": 15, "75": 20, "90": 25},
    "10 AWG": {"60": 25, "75": 30, "90": 35},
    "8 AWG": {"60": 30, "75": 40, "90": 45},
    "6 AWG": {"60": 40, "75": 50, "90": 60},
    "4 AWG": {"60": 55, "75": 65, "90": 75},
    "3 AWG": {"60": 65, "75": 75, "90": 85},
    "2 AWG": {"60": 75, "75": 90, "90": 100},
    "1 AWG": {"60": 85, "75": 100, "90": 115},
    "1/0 AWG": {"60": 100, "75": 120, "90": 135},
    "2/0 AWG": {"60": 115, "75": 135, "90": 150},
    "3/0 AWG": {"60": 130, "75": 155, "90": 175},
    "4/0 AWG": {"60": 150, "75": 180, "90": 205},
}

# Small-conductor overcurrent limits commonly applied to branch circuits.
SMALL_CONDUCTOR_OCPD: dict[tuple[str, str], int] = {
    ("copper", "14 AWG"): 15,
    ("copper", "12 AWG"): 20,
    ("copper", "10 AWG"): 30,
    ("aluminum", "12 AWG"): 15,
    ("aluminum", "10 AWG"): 25,
}

# Cubic inches per conductor, by AWG, for box-fill planning.
BOX_FILL_ALLOWANCE_CUIN: dict[str, float] = {
    "18 AWG": 1.50,
    "16 AWG": 1.75,
    "14 AWG": 2.00,
    "12 AWG": 2.25,
    "10 AWG": 2.50,
    "8 AWG": 3.00,
    "6 AWG": 5.00,
}

# Approximate 100% internal area (sq in) by raceway type and trade size.
CONDUIT_AREA_SQIN: dict[str, dict[str, float]] = {
    "EMT": {
        "1/2": 0.304,
        "3/4": 0.533,
        "1": 0.864,
        "1-1/4": 1.496,
        "1-1/2": 2.036,
        "2": 3.356,
        "2-1/2": 5.858,
        "3": 8.846,
        "3-1/2": 11.545,
        "4": 15.072,
    },
    "PVC-40": {
        "1/2": 0.285,
        "3/4": 0.508,
        "1": 0.829,
        "1-1/4": 1.453,
        "1-1/2": 1.986,
        "2": 3.291,
        "2-1/2": 4.695,
        "3": 7.268,
        "3-1/2": 9.737,
        "4": 12.573,
    },
    "RMC": {
        "1/2": 0.314,
        "3/4": 0.549,
        "1": 0.887,
        "1-1/4": 1.526,
        "1-1/2": 2.071,
        "2": 3.408,
        "2-1/2": 4.866,
        "3": 7.499,
        "3-1/2": 10.010,
        "4": 12.882,
    },
}

# Approximate THHN/THWN conductor area (sq in).
THHN_AREA_SQIN: dict[str, float] = {
    "14 AWG": 0.0097,
    "12 AWG": 0.0133,
    "10 AWG": 0.0211,
    "8 AWG": 0.0366,
    "6 AWG": 0.0507,
    "4 AWG": 0.0824,
    "3 AWG": 0.0973,
    "2 AWG": 0.1158,
    "1 AWG": 0.1562,
    "1/0 AWG": 0.1893,
    "2/0 AWG": 0.2265,
    "3/0 AWG": 0.2752,
    "4/0 AWG": 0.3288,
}

STANDARD_BREAKERS_AMPS: tuple[int, ...] = (
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    60,
    70,
    80,
    90,
    100,
    110,
    125,
    150,
    175,
    200,
    225,
    250,
    300,
    350,
    400,
)

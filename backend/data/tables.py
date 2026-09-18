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

# Commonly published single-phase motor full-load current, in amperes by
# horsepower and system voltage (table-lookup style, mirrors NEC Table
# 430.248 in shape). Nameplate FLA always takes precedence over this table.
MOTOR_FLC_SINGLE_PHASE: dict[str, dict[str, float]] = {
    "1/6": {"115": 4.4, "200": 2.5, "208": 2.4, "230": 2.2},
    "1/4": {"115": 5.8, "200": 3.3, "208": 3.2, "230": 2.9},
    "1/3": {"115": 7.2, "200": 4.1, "208": 4.0, "230": 3.6},
    "1/2": {"115": 9.8, "200": 5.6, "208": 5.4, "230": 4.9},
    "3/4": {"115": 13.8, "200": 7.9, "208": 7.6, "230": 6.9},
    "1": {"115": 16.0, "200": 9.2, "208": 8.8, "230": 8.0},
    "1.5": {"115": 20.0, "200": 11.5, "208": 11.0, "230": 10.0},
    "2": {"115": 24.0, "200": 13.8, "208": 13.2, "230": 12.0},
    "3": {"115": 34.0, "200": 19.6, "208": 18.7, "230": 17.0},
    "5": {"115": 56.0, "200": 32.2, "208": 30.8, "230": 28.0},
    "7.5": {"115": 80.0, "200": 46.0, "208": 44.0, "230": 40.0},
    "10": {"115": 100.0, "200": 57.5, "208": 55.0, "230": 50.0},
}

# Commonly published three-phase motor full-load current, in amperes by
# horsepower and system voltage (table-lookup style, mirrors NEC Table
# 430.250 in shape). Nameplate FLA always takes precedence over this table.
MOTOR_FLC_THREE_PHASE: dict[str, dict[str, float]] = {
    "1/2": {"200": 2.5, "208": 2.4, "230": 2.2, "460": 1.1, "575": 0.9},
    "3/4": {"200": 3.7, "208": 3.5, "230": 3.2, "460": 1.6, "575": 1.3},
    "1": {"200": 4.8, "208": 4.6, "230": 4.2, "460": 2.1, "575": 1.7},
    "1.5": {"200": 6.9, "208": 6.6, "230": 6.0, "460": 3.0, "575": 2.4},
    "2": {"200": 7.8, "208": 7.5, "230": 6.8, "460": 3.4, "575": 2.7},
    "3": {"200": 11.0, "208": 10.6, "230": 9.6, "460": 4.8, "575": 3.9},
    "5": {"200": 17.5, "208": 16.7, "230": 15.2, "460": 7.6, "575": 6.1},
    "7.5": {"200": 25.3, "208": 24.2, "230": 22.0, "460": 11.0, "575": 9.0},
    "10": {"200": 32.2, "208": 30.8, "230": 28.0, "460": 14.0, "575": 11.0},
    "15": {"200": 48.3, "208": 46.2, "230": 42.0, "460": 21.0, "575": 17.0},
    "20": {"200": 62.1, "208": 59.4, "230": 54.0, "460": 27.0, "575": 22.0},
    "25": {"200": 78.2, "208": 74.8, "230": 68.0, "460": 34.0, "575": 27.0},
    "30": {"200": 92.0, "208": 88.0, "230": 80.0, "460": 40.0, "575": 32.0},
    "40": {"200": 120.0, "208": 114.0, "230": 104.0, "460": 52.0, "575": 41.0},
    "50": {"200": 150.0, "208": 143.0, "230": 130.0, "460": 65.0, "575": 52.0},
    "60": {"200": 177.0, "208": 169.0, "230": 154.0, "460": 77.0, "575": 62.0},
    "75": {"200": 221.0, "208": 211.0, "230": 192.0, "460": 96.0, "575": 77.0},
    "100": {"200": 285.0, "208": 273.0, "230": 248.0, "460": 124.0, "575": 99.0},
    "125": {"200": 359.0, "208": 343.0, "230": 312.0, "460": 156.0, "575": 125.0},
    "150": {"200": 414.0, "208": 396.0, "230": 360.0, "460": 180.0, "575": 144.0},
    "200": {"200": 552.0, "208": 528.0, "230": 480.0, "460": 240.0, "575": 192.0},
}

# Length units, expressed as meters per unit.
LENGTH_TO_METERS: dict[str, float] = {
    "ft": 0.3048,
    "in": 0.0254,
    "m": 1.0,
    "cm": 0.01,
    "mm": 0.001,
}

# Power units, expressed as watts per unit. 1 HP = 746 W (electrical HP).
POWER_TO_WATTS: dict[str, float] = {
    "W": 1.0,
    "kW": 1000.0,
    "HP": 746.0,
}

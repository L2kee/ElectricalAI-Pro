"""Function-calling tools that let the AI look up real calculator results
instead of guessing ampacity, full-load current, voltage drop, and other
numeric values from training data.

Each tool wraps an existing calculator service, so the AI gets exactly the
same numbers the calculator screens show. Argument errors are returned to
the model as {"error": ...} rather than raised, so it can see what went
wrong and retry with corrected arguments instead of the whole turn failing.
"""

from __future__ import annotations

from typing import Any, Callable

from backend.services.errors import CalculatorError
from backend.services.registry import (
    box_fill_service,
    circuit_load_service,
    conduit_fill_service,
    motor_flc_service,
    ohms_service,
    transformer_sizing_service,
    unit_conversion_service,
    voltage_drop_service,
    wire_ampacity_service,
)


def _ohms_law_tool(args: dict[str, Any]) -> dict[str, Any]:
    return ohms_service.calculate(
        voltage=args.get("voltage"),
        current=args.get("current"),
        resistance=args.get("resistance"),
    )


def _voltage_drop_tool(args: dict[str, Any]) -> dict[str, Any]:
    return voltage_drop_service.calculate(
        current=args["current"],
        wire_size=args["wire_size"],
        length_ft=args["length_ft"],
        material=args.get("material", "copper"),
        voltage=args.get("voltage", 120),
        phase=args.get("phase", "single"),
    )


def _wire_ampacity_tool(args: dict[str, Any]) -> dict[str, Any]:
    return wire_ampacity_service.calculate(
        wire_size=args["wire_size"],
        temperature_rating=args["temperature_rating"],
        material=args.get("material", "copper"),
    )


def _box_fill_tool(args: dict[str, Any]) -> dict[str, Any]:
    return box_fill_service.calculate(
        box_volume=args["box_volume"],
        conductor_size=args["conductor_size"],
        conductor_count=args["conductor_count"],
        device_count=args.get("device_count", 0),
        clamp_count=args.get("clamp_count", 0),
        equipment_ground_count=args.get("equipment_ground_count", 0),
    )


def _conduit_fill_tool(args: dict[str, Any]) -> dict[str, Any]:
    return conduit_fill_service.calculate(
        conduit_type=args["conduit_type"],
        trade_size=args["trade_size"],
        wire_size=args["wire_size"],
        wire_count=args["wire_count"],
    )


def _circuit_load_tool(args: dict[str, Any]) -> dict[str, Any]:
    return circuit_load_service.calculate(
        power=args.get("power"),
        voltage=args.get("voltage"),
        current=args.get("current"),
        continuous=args.get("continuous", False),
    )


def _motor_flc_tool(args: dict[str, Any]) -> dict[str, Any]:
    return motor_flc_service.calculate(
        horsepower=args["horsepower"],
        voltage=args["voltage"],
        phase=args.get("phase", "three"),
    )


def _transformer_sizing_tool(args: dict[str, Any]) -> dict[str, Any]:
    return transformer_sizing_service.calculate(
        kva=args["kva"],
        primary_voltage=args["primary_voltage"],
        secondary_voltage=args["secondary_voltage"],
        phase=args.get("phase", "three"),
    )


def _unit_conversion_tool(args: dict[str, Any]) -> dict[str, Any]:
    return unit_conversion_service.convert(
        category=args["category"],
        from_unit=args["from_unit"],
        to_unit=args["to_unit"],
        value=args["value"],
    )


_TOOL_FUNCTIONS: dict[str, Callable[[dict[str, Any]], dict[str, Any]]] = {
    "ohms_law": _ohms_law_tool,
    "voltage_drop": _voltage_drop_tool,
    "wire_ampacity": _wire_ampacity_tool,
    "box_fill": _box_fill_tool,
    "conduit_fill": _conduit_fill_tool,
    "circuit_load": _circuit_load_tool,
    "motor_flc": _motor_flc_tool,
    "transformer_sizing": _transformer_sizing_tool,
    "unit_conversion": _unit_conversion_tool,
}


def call_tool(name: str, arguments: dict[str, Any]) -> dict[str, Any]:
    """Run a tool by name and return its result, or {"error": ...} on bad input."""
    tool = _TOOL_FUNCTIONS.get(name)
    if tool is None:
        return {"error": f"Unknown tool: {name}"}
    if not isinstance(arguments, dict):
        return {"error": "Arguments must be a JSON object."}
    try:
        return tool(arguments)
    except CalculatorError as exc:
        return {"error": str(exc)}
    except (KeyError, TypeError, AttributeError) as exc:
        return {"error": f"Missing or invalid argument: {exc}"}


TOOLS: list[dict[str, Any]] = [
    {
        "type": "function",
        "function": {
            "name": "ohms_law",
            "description": (
                "Solve Ohm's law for voltage, current, or resistance. "
                "Provide exactly two of the three values; the tool solves for the missing one."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "voltage": {"type": "number", "description": "Voltage in volts."},
                    "current": {"type": "number", "description": "Current in amps."},
                    "resistance": {"type": "number", "description": "Resistance in ohms."},
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "voltage_drop",
            "description": "Calculate conductor voltage drop for a branch circuit or feeder run.",
            "parameters": {
                "type": "object",
                "properties": {
                    "current": {"type": "number", "description": "Load current in amps."},
                    "wire_size": {
                        "type": "string",
                        "description": "Conductor size, e.g. '12 AWG', '1/0 AWG', '250 kcmil'.",
                    },
                    "length_ft": {"type": "number", "description": "One-way circuit length in feet."},
                    "material": {"type": "string", "enum": ["copper", "aluminum"]},
                    "voltage": {"type": "number", "description": "System voltage. Defaults to 120."},
                    "phase": {"type": "string", "enum": ["single", "three"]},
                },
                "required": ["current", "wire_size", "length_ft"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "wire_ampacity",
            "description": "Look up allowable conductor ampacity by wire size, material, and temperature rating.",
            "parameters": {
                "type": "object",
                "properties": {
                    "wire_size": {"type": "string", "description": "e.g. '12 AWG', '4/0 AWG'."},
                    "temperature_rating": {"type": "string", "enum": ["60", "75", "90"]},
                    "material": {"type": "string", "enum": ["copper", "aluminum"]},
                },
                "required": ["wire_size", "temperature_rating"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "box_fill",
            "description": "Calculate required electrical box volume from conductors, devices, clamps, and grounds.",
            "parameters": {
                "type": "object",
                "properties": {
                    "box_volume": {"type": "number", "description": "Box volume in cubic inches."},
                    "conductor_size": {"type": "string", "description": "e.g. '12 AWG'."},
                    "conductor_count": {"type": "integer"},
                    "device_count": {"type": "integer", "description": "Switches/receptacles. Defaults to 0."},
                    "clamp_count": {"type": "integer", "description": "Internal cable clamps. Defaults to 0."},
                    "equipment_ground_count": {"type": "integer", "description": "Defaults to 0."},
                },
                "required": ["box_volume", "conductor_size", "conductor_count"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "conduit_fill",
            "description": "Calculate conduit fill percentage for THHN conductors in EMT, PVC-40, or RMC.",
            "parameters": {
                "type": "object",
                "properties": {
                    "conduit_type": {"type": "string", "enum": ["EMT", "PVC-40", "RMC"]},
                    "trade_size": {"type": "string", "description": "e.g. '1/2', '3/4', '1', '2'."},
                    "wire_size": {"type": "string", "description": "e.g. '12 AWG'."},
                    "wire_count": {"type": "integer"},
                },
                "required": ["conduit_type", "trade_size", "wire_size", "wire_count"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "circuit_load",
            "description": (
                "Solve P = V x I for power, voltage, or current. Provide exactly two of the "
                "three; optionally apply the 125% continuous-load factor and get the next "
                "standard breaker size."
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "power": {"type": "number", "description": "Power in watts."},
                    "voltage": {"type": "number"},
                    "current": {"type": "number"},
                    "continuous": {"type": "boolean", "description": "3 hours or more. Defaults to false."},
                },
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "motor_flc",
            "description": "Look up motor full-load current by horsepower, voltage, and phase.",
            "parameters": {
                "type": "object",
                "properties": {
                    "horsepower": {"type": "string", "description": "e.g. '1/2', '5', '10'."},
                    "voltage": {"type": "string", "description": "e.g. '115', '230', '460'."},
                    "phase": {"type": "string", "enum": ["single", "three"]},
                },
                "required": ["horsepower", "voltage"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "transformer_sizing",
            "description": "Calculate transformer primary and secondary full-load amperes from rated kVA.",
            "parameters": {
                "type": "object",
                "properties": {
                    "kva": {"type": "number"},
                    "primary_voltage": {"type": "number"},
                    "secondary_voltage": {"type": "number"},
                    "phase": {"type": "string", "enum": ["single", "three"]},
                },
                "required": ["kva", "primary_voltage", "secondary_voltage"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "unit_conversion",
            "description": "Convert between common length, power, or temperature units.",
            "parameters": {
                "type": "object",
                "properties": {
                    "category": {"type": "string", "enum": ["length", "power", "temperature"]},
                    "from_unit": {
                        "type": "string",
                        "description": (
                            "Length: ft, in, m, cm, mm. Power: W, kW, HP. Temperature: C, F."
                        ),
                    },
                    "to_unit": {"type": "string"},
                    "value": {"type": "number"},
                },
                "required": ["category", "from_unit", "to_unit", "value"],
            },
        },
    },
]

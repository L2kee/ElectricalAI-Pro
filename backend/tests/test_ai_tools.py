import unittest

from backend.ai.tools import TOOLS, call_tool


class CallToolTests(unittest.TestCase):
    def test_ohms_law(self):
        result = call_tool("ohms_law", {"voltage": 120, "resistance": 12})
        self.assertEqual(result["current"], 10)

    def test_voltage_drop(self):
        result = call_tool(
            "voltage_drop",
            {"current": 16, "wire_size": "12 AWG", "length_ft": 75, "material": "copper", "voltage": 120, "phase": "single"},
        )
        self.assertEqual(result["voltage_drop"], 4.63)

    def test_wire_ampacity(self):
        result = call_tool(
            "wire_ampacity", {"wire_size": "12 AWG", "temperature_rating": "75", "material": "copper"}
        )
        self.assertEqual(result["ampacity"], 25)

    def test_box_fill(self):
        result = call_tool(
            "box_fill",
            {
                "box_volume": 18,
                "conductor_size": "12 AWG",
                "conductor_count": 4,
                "device_count": 1,
                "clamp_count": 1,
                "equipment_ground_count": 1,
            },
        )
        self.assertTrue(result["box_is_large_enough"])

    def test_conduit_fill(self):
        result = call_tool(
            "conduit_fill",
            {"conduit_type": "EMT", "trade_size": "1/2", "wire_size": "12 AWG", "wire_count": 3},
        )
        self.assertTrue(result["within_limit"])

    def test_circuit_load(self):
        result = call_tool("circuit_load", {"power": 2400, "voltage": 120})
        self.assertEqual(result["current"], 20.0)

    def test_motor_flc(self):
        result = call_tool("motor_flc", {"horsepower": "10", "voltage": "230", "phase": "three"})
        self.assertEqual(result["full_load_current"], 28.0)

    def test_transformer_sizing(self):
        result = call_tool(
            "transformer_sizing",
            {"kva": 75, "primary_voltage": 480, "secondary_voltage": 208, "phase": "three"},
        )
        self.assertEqual(result["secondary_fla"], 208.19)

    def test_unit_conversion(self):
        result = call_tool("unit_conversion", {"category": "length", "from_unit": "ft", "to_unit": "m", "value": 100})
        self.assertEqual(result["result"], 30.48)

    def test_unknown_tool_returns_error(self):
        result = call_tool("not_a_real_tool", {})
        self.assertIn("error", result)

    def test_calculator_error_is_returned_not_raised(self):
        result = call_tool("wire_ampacity", {"wire_size": "99 AWG", "temperature_rating": "75"})
        self.assertIn("error", result)

    def test_missing_required_argument_returns_error(self):
        result = call_tool("voltage_drop", {"current": 16, "wire_size": "12 AWG"})
        self.assertIn("error", result)

    def test_every_tool_has_a_dispatch_function(self):
        tool_names = {tool["function"]["name"] for tool in TOOLS}
        for name in tool_names:
            result = call_tool(name, {})
            # Whatever the outcome (success or a validation error), it must
            # not raise and must not be "unknown tool".
            self.assertNotEqual(result.get("error"), f"Unknown tool: {name}")

    def test_non_dict_arguments_return_error_instead_of_crashing(self):
        # A model can emit tool-call arguments that decode to valid JSON but
        # aren't an object, e.g. "[120, 12]". This must not raise.
        for bad_arguments in ([120, 12], "not an object", 42, None):
            result = call_tool("ohms_law", bad_arguments)
            self.assertIn("error", result)


if __name__ == "__main__":
    unittest.main()

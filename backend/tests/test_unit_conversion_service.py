import unittest

from backend.services.errors import CalculatorError
from backend.services.unit_conversion_service import UnitConversionService


class UnitConversionServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = UnitConversionService()

    def test_length_feet_to_meters(self):
        result = self.service.convert("length", "ft", "m", 100)
        self.assertEqual(result["result"], 30.48)

    def test_length_inches_to_mm(self):
        result = self.service.convert("length", "in", "mm", 1)
        self.assertEqual(result["result"], 25.4)

    def test_power_hp_to_watts(self):
        result = self.service.convert("power", "HP", "W", 1)
        self.assertEqual(result["result"], 746.0)

    def test_power_watts_to_kw(self):
        result = self.service.convert("power", "W", "kW", 1500)
        self.assertEqual(result["result"], 1.5)

    def test_temperature_celsius_to_fahrenheit(self):
        result = self.service.convert("temperature", "C", "F", 30)
        self.assertEqual(result["result"], 86.0)

    def test_temperature_fahrenheit_to_celsius(self):
        result = self.service.convert("temperature", "F", "C", 86)
        self.assertEqual(result["result"], 30.0)

    def test_temperature_same_unit_is_identity(self):
        result = self.service.convert("temperature", "C", "C", 25)
        self.assertEqual(result["result"], 25)

    def test_rejects_unknown_category(self):
        with self.assertRaises(CalculatorError):
            self.service.convert("mass", "kg", "lb", 1)

    def test_rejects_unknown_length_unit(self):
        with self.assertRaises(CalculatorError):
            self.service.convert("length", "yd", "m", 1)

    def test_rejects_unknown_temperature_unit(self):
        with self.assertRaises(CalculatorError):
            self.service.convert("temperature", "K", "C", 300)

    def test_length_and_power_units_are_case_and_whitespace_insensitive(self):
        result = self.service.convert("length", " FT ", "M", 100)
        self.assertEqual(result["result"], 30.48)
        self.assertEqual(result["from_unit"], "ft")
        self.assertEqual(result["to_unit"], "m")

        result = self.service.convert("power", "hp", "w", 1)
        self.assertEqual(result["result"], 746.0)
        self.assertEqual(result["from_unit"], "HP")
        self.assertEqual(result["to_unit"], "W")


if __name__ == "__main__":
    unittest.main()

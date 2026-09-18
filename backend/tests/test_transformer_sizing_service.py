import unittest

from backend.services.errors import CalculatorError
from backend.services.transformer_sizing_service import TransformerSizingService


class TransformerSizingServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = TransformerSizingService()

    def test_three_phase_75kva_480_to_208(self):
        result = self.service.calculate(75, 480, 208, "three")
        self.assertEqual(result["primary_fla"], 90.21)
        self.assertEqual(result["secondary_fla"], 208.19)
        self.assertEqual(result["phase"], "three-phase")

    def test_single_phase_25kva_240_to_120(self):
        result = self.service.calculate(25, 240, 120, "single")
        self.assertEqual(result["primary_fla"], 104.17)
        self.assertEqual(result["secondary_fla"], 208.33)

    def test_defaults_to_three_phase(self):
        result = self.service.calculate(30, 480, 208)
        self.assertEqual(result["phase"], "three-phase")

    def test_rejects_zero_kva(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate(0, 480, 208, "three")

    def test_rejects_zero_voltage(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate(30, 0, 208, "three")

    def test_rejects_bad_phase(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate(30, 480, 208, "two")


if __name__ == "__main__":
    unittest.main()

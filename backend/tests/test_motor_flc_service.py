import unittest

from backend.services.errors import CalculatorError
from backend.services.motor_flc_service import MotorFlcService


class MotorFlcServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = MotorFlcService()

    def test_three_phase_10hp_230v(self):
        result = self.service.calculate("10", "230", "three")
        self.assertEqual(result["full_load_current"], 28.0)
        self.assertEqual(result["min_conductor_ampacity_amps"], 35.0)
        self.assertEqual(result["phase"], "three-phase")

    def test_single_phase_5hp_115v(self):
        result = self.service.calculate("5", "115", "single")
        self.assertEqual(result["full_load_current"], 56.0)
        self.assertEqual(result["min_conductor_ampacity_amps"], 70.0)

    def test_defaults_to_three_phase(self):
        result = self.service.calculate("1", "230")
        self.assertEqual(result["phase"], "three-phase")
        self.assertEqual(result["full_load_current"], 4.2)

    def test_rejects_unsupported_horsepower(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate("9000", "230", "three")

    def test_rejects_unsupported_voltage(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate("10", "120", "three")

    def test_rejects_bad_phase(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate("10", "230", "two")


if __name__ == "__main__":
    unittest.main()

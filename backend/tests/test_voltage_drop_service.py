import unittest

from backend.services.errors import CalculatorError
from backend.services.voltage_drop_service import VoltageDropService


class VoltageDropServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = VoltageDropService()

    def test_twelve_awg_copper_120v_branch(self):
        result = self.service.calculate(
            current=16,
            wire_size="12 AWG",
            length_ft=75,
            material="copper",
            voltage=120,
            phase="single",
        )
        # 16 A * 1.93 Ω/kft * 0.075 kft * 2 = 4.632 V → 3.86%
        self.assertAlmostEqual(result["voltage_drop"], 4.63, places=2)
        self.assertAlmostEqual(result["percent_drop"], 3.86, places=2)
        self.assertFalse(result["within_3_percent"])
        self.assertTrue(result["within_5_percent"])

    def test_three_phase_uses_1_732(self):
        single = self.service.calculate(
            current=40, wire_size="8 AWG", length_ft=100, voltage=208, phase="single"
        )
        three = self.service.calculate(
            current=40, wire_size="8 AWG", length_ft=100, voltage=208, phase="three"
        )
        self.assertAlmostEqual(
            three["voltage_drop"] / single["voltage_drop"],
            1.732 / 2.0,
            places=3,
        )

    def test_rejects_unknown_size(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate(current=10, wire_size="99 AWG", length_ft=50)


if __name__ == "__main__":
    unittest.main()

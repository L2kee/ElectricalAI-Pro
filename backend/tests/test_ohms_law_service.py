import unittest

from backend.services.errors import CalculatorError
from backend.services.ohms_law_service import OhmsLawService


class OhmsLawServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = OhmsLawService()

    def test_voltage(self):
        result = self.service.calculate(current=10, resistance=12)
        self.assertEqual(result["voltage"], 120)

    def test_current(self):
        result = self.service.calculate(voltage=120, resistance=12)
        self.assertEqual(result["current"], 10)

    def test_rejects_one_value(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate(voltage=120)

    def test_rejects_zero(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate(voltage=120, current=0)


if __name__ == "__main__":
    unittest.main()

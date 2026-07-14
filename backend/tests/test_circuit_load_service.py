import unittest

from backend.services.circuit_load_service import CircuitLoadService


class CircuitLoadServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = CircuitLoadService()

    def test_calculates_current_from_power_and_voltage(self):
        result = self.service.calculate(power=2400, voltage=120)

        self.assertEqual(result["current"], 20.0)

    def test_calculates_power_from_voltage_and_current(self):
        result = self.service.calculate(voltage=120, current=10)

        self.assertEqual(result["power"], 1200.0)

    def test_calculates_voltage_from_power_and_current(self):
        result = self.service.calculate(power=2400, current=20)

        self.assertEqual(result["voltage"], 120.0)

    def test_requires_exactly_two_values(self):
        result = self.service.calculate()

        self.assertEqual(result["error"], "Please provide exactly two values.")


if __name__ == "__main__":
    unittest.main()

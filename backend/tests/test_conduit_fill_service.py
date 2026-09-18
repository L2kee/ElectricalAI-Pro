import unittest

from backend.services.conduit_fill_service import ConduitFillService
from backend.services.errors import CalculatorError


class ConduitFillServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = ConduitFillService()

    def test_three_thhn_in_half_emt(self):
        result = self.service.calculate(
            conduit_type="EMT",
            trade_size="1/2",
            wire_size="12 AWG",
            wire_count=3,
        )
        # 3 * 0.0133 / 0.304 = 13.125% → 13.12 when rounded to 2 places
        self.assertAlmostEqual(result["percent_fill"], 13.12, places=2)
        self.assertEqual(result["fill_limit_percent"], 40.0)
        self.assertTrue(result["within_limit"])

    def test_two_conductors_use_31_percent(self):
        result = self.service.calculate(
            conduit_type="EMT",
            trade_size="1/2",
            wire_size="12 AWG",
            wire_count=2,
        )
        self.assertEqual(result["fill_limit_percent"], 31.0)

    def test_rejects_zero_count(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate("EMT", "1/2", "12 AWG", 0)


if __name__ == "__main__":
    unittest.main()

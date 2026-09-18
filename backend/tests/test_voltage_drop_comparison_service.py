import unittest

from backend.services.errors import CalculatorError
from backend.services.voltage_drop_comparison_service import VoltageDropComparisonService


class VoltageDropComparisonServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = VoltageDropComparisonService()

    def test_returns_a_row_per_wire_size(self):
        result = self.service.compare(current=16, length_ft=75, material="copper", voltage=120, phase="single")
        wire_sizes = [row["wire_size"] for row in result["results"]]
        self.assertEqual(len(wire_sizes), len(set(wire_sizes)))
        self.assertIn("12 AWG", wire_sizes)
        self.assertIn("500 kcmil", wire_sizes)

    def test_finds_smallest_size_within_each_target(self):
        result = self.service.compare(current=16, length_ft=75, material="copper", voltage=120, phase="single")
        self.assertEqual(result["smallest_size_within_3_percent"], "10 AWG")
        self.assertEqual(result["smallest_size_within_5_percent"], "12 AWG")

    def test_matches_single_size_calculation(self):
        result = self.service.compare(current=16, length_ft=75, material="copper", voltage=120, phase="single")
        row_12awg = next(r for r in result["results"] if r["wire_size"] == "12 AWG")
        self.assertEqual(row_12awg["voltage_drop"], 4.63)
        self.assertEqual(row_12awg["percent_drop"], 3.86)
        self.assertFalse(row_12awg["within_3_percent"])
        self.assertTrue(row_12awg["within_5_percent"])

    def test_results_are_ordered_smallest_to_largest_conductor(self):
        result = self.service.compare(current=16, length_ft=75, material="copper", voltage=120, phase="single")
        percents = [row["percent_drop"] for row in result["results"]]
        self.assertEqual(percents, sorted(percents, reverse=True))

    def test_rejects_zero_current(self):
        with self.assertRaises(CalculatorError):
            self.service.compare(current=0, length_ft=75)

    def test_none_when_no_size_meets_target(self):
        # Absurdly long run at high current: even 500 kcmil misses both targets.
        result = self.service.compare(current=200, length_ft=2000, material="copper", voltage=120, phase="single")
        self.assertIsNone(result["smallest_size_within_3_percent"])
        self.assertIsNone(result["smallest_size_within_5_percent"])


if __name__ == "__main__":
    unittest.main()

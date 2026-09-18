import unittest

from backend.services.errors import CalculatorError
from backend.services.phase import normalize_phase


class NormalizePhaseTests(unittest.TestCase):
    def test_accepts_single_aliases(self):
        for value in ("single", "1", "1ph", "single-phase", "SINGLE", " Single "):
            self.assertEqual(normalize_phase(value), "single")

    def test_accepts_three_aliases(self):
        for value in ("three", "3", "3ph", "three-phase", "THREE", " Three "):
            self.assertEqual(normalize_phase(value), "three")

    def test_rejects_unknown_phase(self):
        with self.assertRaises(CalculatorError):
            normalize_phase("two")


if __name__ == "__main__":
    unittest.main()

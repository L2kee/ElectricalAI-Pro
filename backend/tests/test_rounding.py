import unittest

from backend.services.rounding import round_half_up


class RoundHalfUpTests(unittest.TestCase):
    def test_rounds_exact_tie_up(self):
        self.assertEqual(round_half_up(3.125, 2), 3.13)

    def test_rounds_non_tie_normally(self):
        self.assertEqual(round_half_up(90.2137, 2), 90.21)

    def test_no_op_when_already_precise(self):
        self.assertEqual(round_half_up(35.0, 2), 35.0)


if __name__ == "__main__":
    unittest.main()

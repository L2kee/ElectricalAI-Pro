import unittest

from backend.services.errors import CalculatorError
from backend.services.wire_ampacity_service import WireAmpacityService


class WireAmpacityServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = WireAmpacityService()

    def test_copper_12_awg_75c(self):
        result = self.service.calculate("12 AWG", "75", "copper")
        self.assertEqual(result["ampacity"], 25)
        self.assertEqual(result["typical_branch_ocpd_amps"], 20)

    def test_aluminum_6_awg_75c(self):
        result = self.service.calculate("6 AWG", "75C", "aluminum")
        self.assertEqual(result["ampacity"], 50)

    def test_rejects_copper_size_missing_from_aluminum_only_path(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate("14 AWG", "90", "aluminum")


if __name__ == "__main__":
    unittest.main()

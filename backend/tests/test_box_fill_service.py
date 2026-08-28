import unittest

from backend.services.box_fill_service import BoxFillService
from backend.services.errors import CalculatorError


class BoxFillServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = BoxFillService()

    def test_device_counts_as_two_and_grounds_once(self):
        result = self.service.calculate(
            box_volume=18,
            conductor_size="12 AWG",
            conductor_count=4,
            device_count=1,
            clamp_count=2,
            equipment_ground_count=3,
        )
        # 12 AWG = 2.25 cu in
        # conductors 4*2.25=9, device 2*2.25=4.5, clamps once 2.25, grounds once 2.25 → 18
        self.assertEqual(result["required_volume"], 18.0)
        self.assertTrue(result["box_is_large_enough"])
        self.assertEqual(result["clamp_volume"], 2.25)
        self.assertEqual(result["ground_volume"], 2.25)

    def test_too_small(self):
        result = self.service.calculate(
            box_volume=8,
            conductor_size="14 AWG",
            conductor_count=6,
            device_count=1,
        )
        self.assertFalse(result["box_is_large_enough"])

    def test_rejects_unknown_size(self):
        with self.assertRaises(CalculatorError):
            self.service.calculate(box_volume=18, conductor_size="4/0 AWG", conductor_count=2)


if __name__ == "__main__":
    unittest.main()

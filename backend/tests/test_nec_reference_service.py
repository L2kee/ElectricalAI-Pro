import unittest

from backend.services.nec_reference_service import NecReferenceService


class NecReferenceServiceTests(unittest.TestCase):
    def setUp(self):
        self.service = NecReferenceService()
        self.reference = self.service.get_reference()

    def test_includes_standard_breaker_sizes(self):
        amps = self.reference["standard_breaker_fuse_amps"]
        self.assertIn(20, amps)
        self.assertIn(100, amps)
        self.assertEqual(amps, sorted(amps))

    def test_includes_box_volumes(self):
        volumes = {row["box_type"]: row["volume_cuin"] for row in self.reference["box_volumes"]}
        self.assertEqual(volumes["4 in square, 1-1/2 in deep"], 21.0)
        self.assertEqual(volumes["3 x 2 x 2 in device box"], 10.0)

    def test_includes_conduit_bend_radius(self):
        radii = {row["trade_size"]: row for row in self.reference["conduit_bend_radius"]}
        self.assertEqual(radii["1/2"]["one_shot_in"], 4.0)
        self.assertEqual(radii["1/2"]["other_bends_in"], 4.0)
        self.assertEqual(radii["4"]["other_bends_in"], 21.0)

    def test_bend_radius_all_entries_are_clean_fractions(self):
        # Every published Chapter 9 Table 2 value lands on a quarter-inch
        # increment; a value like 10.55 would be a transcription error.
        for row in self.reference["conduit_bend_radius"]:
            for key in ("one_shot_in", "other_bends_in"):
                value = row[key]
                self.assertEqual(
                    value, round(value * 4) / 4, f"{row['trade_size']} {key} is not a quarter-inch value"
                )

    def test_two_and_half_inch_one_shot_bend_radius(self):
        radii = {row["trade_size"]: row for row in self.reference["conduit_bend_radius"]}
        self.assertEqual(radii["2-1/2"]["one_shot_in"], 10.5)

    def test_no_duplicate_box_types(self):
        box_types = [row["box_type"] for row in self.reference["box_volumes"]]
        self.assertEqual(len(box_types), len(set(box_types)))

    def test_includes_notes(self):
        self.assertIn("Reference values only", self.reference["notes"])


if __name__ == "__main__":
    unittest.main()

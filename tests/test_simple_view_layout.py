import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LAYOUT_PATH = ROOT / "resources" / "layouts" / "layout.xml"
VIEW_PATH = ROOT / "source" / "Views" / "SimpleView.mc"


class SimpleViewLayoutTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        root = ET.parse(LAYOUT_PATH).getroot()
        layout = root.find("./layout[@id='MainLayout']")
        cls.labels = {
            label.attrib["id"]: label.attrib
            for label in layout.findall("label")
        }
        cls.view_source = VIEW_PATH.read_text(encoding="utf-8")

    def test_reference_design_fields_exist(self):
        expected = {
            "time_text",
            "cadence_text",
            "cadence_percent",
            "cadence_zone",
            "cadence_range",
            "heartrate_text",
            "distance_text",
            "pace_text",
        }
        self.assertTrue(expected.issubset(self.labels))

    def test_live_values_use_separate_left_and_right_columns(self):
        self.assertEqual("Gfx.TEXT_JUSTIFY_LEFT", self.labels["heartrate_text"]["justification"])
        self.assertEqual("Gfx.TEXT_JUSTIFY_RIGHT", self.labels["distance_text"]["justification"])
        self.assertLess(
            int(self.labels["heartrate_text"]["x"].rstrip("%")),
            int(self.labels["distance_text"]["x"].rstrip("%")),
        )

    def test_cadence_status_and_range_have_safe_column_spacing(self):
        self.assertEqual("14%", self.labels["cadence_zone"]["x"])
        self.assertEqual("88%", self.labels["cadence_range"]["x"])
        self.assertIn('zoneText = "below";', self.view_source)
        self.assertIn('zoneText = "above";', self.view_source)

    def test_metric_icons_are_drawn_on_their_text_rows(self):
        self.assertIn("Rez.Drawables.MainHeartRateIcon", self.view_source)
        self.assertIn("(dc.getHeight() * 0.50).toNumber()", self.view_source)
        self.assertIn("(dc.getHeight() * 0.70).toNumber()", self.view_source)
        self.assertIn("MAIN_VIBRATION_ICON_BOTTOM_MARGIN = 0.05", self.view_source)

    def test_screen_is_cleared_before_layout_is_redrawn(self):
        update_start = self.view_source.index("function onUpdate(dc as Dc)")
        update_end = self.view_source.index("function updateCadenceLogic", update_start)
        update = self.view_source[update_start:update_end]

        self.assertLess(update.index("dc.clear();"), update.index("View.onUpdate(dc)"))

    def test_dynamic_strings_include_units_and_safe_defaults(self):
        self.assertIn('"-- SPM"', self.view_source)
        self.assertIn('"00:00:00"', self.view_source)
        self.assertIn('"-- KM"', self.view_source)
        self.assertIn('"--:-- min/km"', self.view_source)


if __name__ == "__main__":
    unittest.main()

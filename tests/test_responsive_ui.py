import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VIEWS = ROOT / "source" / "Views"
SETTINGS_VIEWS = VIEWS / "SettingsViews"


def source(path):
    return path.read_text(encoding="utf-8")


class ResponsiveUiTests(unittest.TestCase):
    def test_all_declared_products_are_covered_by_compact_or_large_layouts(self):
        manifest = ET.parse(ROOT / "manifest.xml")
        namespace = {"iq": "http://www.garmin.com/xml/connectiq"}
        products = {
            product.attrib["id"]
            for product in manifest.findall(".//iq:product", namespace)
        }

        compact = {
            "fenix7", "fenix7pro", "fenix7s", "fr245", "fr255",
            "fr255m", "fr255s", "fr255sm", "fr955",
        }
        large = {"fr165", "fr165m", "fr265", "fr265s", "vivoactive5"}
        self.assertEqual(products, compact | large)

    def test_main_screen_selects_compact_metric_icons(self):
        text = source(VIEWS / "SimpleView.mc")
        self.assertIn("var compact = dc.getWidth() < 300;", text)
        for resource in (
            "PaceIconCompact",
            "MainHeartRateIconCompact",
            "MainVibrationOnIconCompact",
            "MainVibrationOffIconCompact",
        ):
            self.assertIn(resource, text)
        self.assertIn("var iconWidth = icon.getWidth();", text)
        self.assertIn("var iconHeight = icon.getHeight();", text)

    def test_settings_cards_use_shared_responsive_renderer(self):
        renderer = source(VIEWS / "SettingsCardRenderer.mc")
        self.assertIn("var compact = width < 300;", renderer)
        self.assertIn("compact ? Graphics.FONT_SMALL : Graphics.FONT_MEDIUM", renderer)

        cards = (
            VIEWS / "SettingsView.mc",
            SETTINGS_VIEWS / "CadenceSettingsMenuView.mc",
            SETTINGS_VIEWS / "BarChartSettingsMenuView.mc",
            SETTINGS_VIEWS / "PostFeedbackSettingsView.mc",
            SETTINGS_VIEWS / "ProfileSettingsMenuView.mc",
            SETTINGS_VIEWS / "VibrationsOnSettingsView.mc",
            SETTINGS_VIEWS / "VibrationsOffSettingsView.mc",
        )
        for card in cards:
            with self.subTest(card=card.name):
                text = source(card)
                self.assertIn("dc.getWidth() < 300", text)
                self.assertIn("Compact", text)
                self.assertIn("SettingsCardRenderer.draw", text)

    def test_activity_and_summary_screens_have_compact_paths(self):
        cases = {
            VIEWS / "CadenceQualityView.mc": "FeedbackHeartRateIconCompact",
            VIEWS / "FeedbackSummaryView.mc": "FeedbackHeartRateIconCompact",
            VIEWS / "StartConfirmView.mc": "RecIconCompact",
            SETTINGS_VIEWS / "ResetSettingsView.mc": "ResetIconCompact",
            SETTINGS_VIEWS / "SummarySettingsMenuView.mc": "SummaryIconCompact",
        }
        for path, expected in cases.items():
            with self.subTest(path=path.name):
                text = source(path)
                self.assertIn("< 300", text)
                self.assertIn(expected, text)

    def test_main_layout_uses_relative_positions(self):
        layout = source(ROOT / "resources" / "layouts" / "layout.xml")
        main = layout.split("</layout>", 1)[0]
        for label_id in (
            "time_text",
            "cadence_text",
            "cadence_percent",
            "cadence_zone",
            "cadence_range",
            "heartrate_text",
            "distance_text",
            "pace_text",
        ):
            self.assertIn(f'id="{label_id}"', main)
        self.assertNotRegex(main, r'[xy]="\d+"')


if __name__ == "__main__":
    unittest.main()

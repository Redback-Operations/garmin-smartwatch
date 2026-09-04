"""Regression tests for Garmin-style continuous screen navigation."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SETTINGS_PAGES = ["settings", "cadence", "bar_chart", "summary", "reset"]


class NavigationModel:
    def __init__(self, pages, start=0):
        self.pages = pages
        self.index = start
        self.events = []

    @property
    def page(self):
        return self.pages[self.index]

    def down(self):
        previous = self.page
        self.index = (self.index + 1) % len(self.pages)
        self.events.append(f"[NAV] direction=DOWN from={previous} to={self.page}")

    def up(self):
        previous = self.page
        self.index = (self.index - 1) % len(self.pages)
        self.events.append(f"[NAV] direction=UP from={previous} to={self.page}")


class ScreenNavigationTests(unittest.TestCase):
    def source(self, relative_path):
        return (ROOT / relative_path).read_text()

    def test_settings_pages_loop_in_both_directions(self):
        navigation = NavigationModel(SETTINGS_PAGES)

        for _ in range(50):
            for _ in SETTINGS_PAGES:
                navigation.down()
            self.assertEqual("settings", navigation.page)

            for _ in SETTINGS_PAGES:
                navigation.up()
            self.assertEqual("settings", navigation.page)

        print("\nSettings navigation evidence (final loop):")
        for event in navigation.events[-10:]:
            print(event)
        print("[NAV TEST] settings_cycles=50 wrapped=true crashes=0")

    def test_workout_pages_loop_and_preserve_selected_home(self):
        for home_page in ("simple", "time"):
            navigation = NavigationModel([home_page, "advanced"])

            for _ in range(50):
                navigation.down()
                navigation.down()
                self.assertEqual(home_page, navigation.page)
                navigation.up()
                navigation.up()
                self.assertEqual(home_page, navigation.page)

        print("[NAV TEST] workout_cycles=50 homes=simple,time wrapped=true")

    def test_garmin_direction_and_animation_mapping(self):
        source = self.source("source/Navigation/ScreenNavigation.mc")

        self.assertIn("next-page behavior to DOWN / swipe UP", source)
        self.assertIn("previous-page behavior to", source)
        self.assertIn("UP / swipe DOWN", source)
        self.assertIn("isNext ? WatchUi.SLIDE_UP : WatchUi.SLIDE_DOWN", source)

    def test_workout_delegates_use_page_behaviors(self):
        delegates = [
            "source/Delegates/SimpleViewDelegate.mc",
            "source/Delegates/AdvancedViewDelegate.mc",
            "source/Delegates/TimeViewDelegate.mc",
        ]

        for delegate in delegates:
            source = self.source(delegate)
            self.assertIn("function onNextPage()", source)
            self.assertIn("function onPreviousPage()", source)
            self.assertNotIn("WatchUi.KEY_UP", source)
            self.assertNotIn("WatchUi.KEY_DOWN", source)

    def test_every_active_settings_page_uses_central_navigation(self):
        delegates = {
            "source/Delegates/SettingsDelegates/SettingsMenuDelegate.mc": "SETTINGS_ROOT",
            "source/Delegates/SettingsDelegates/SettingsMenuDelegates/CadenceSettingsMenuDelegate.mc": "SETTINGS_CADENCE",
            "source/Delegates/SettingsDelegates/SettingsMenuDelegates/BarChartSettingsMenuDelegate.mc": "SETTINGS_BAR_CHART",
            "source/Delegates/SettingsDelegates/SettingsMenuDelegates/SummarySettingsMenuDelegate.mc": "SETTINGS_SUMMARY",
            "source/Delegates/SettingsDelegates/SettingsMenuDelegates/ResetSettingsDelegate.mc": "SETTINGS_RESET",
        }

        for delegate, page_constant in delegates.items():
            source = self.source(delegate)
            self.assertIn(
                f"showNextSettingsPage(ScreenNavigation.{page_constant})",
                source,
            )
            self.assertIn(
                f"showPreviousSettingsPage(ScreenNavigation.{page_constant})",
                source,
            )

    def test_page_cycles_replace_views_instead_of_growing_stack(self):
        source = self.source("source/Navigation/ScreenNavigation.mc")

        self.assertIn("WatchUi.switchToView", source)
        self.assertNotIn("WatchUi.pushView", source)


if __name__ == "__main__":
    unittest.main(verbosity=2)

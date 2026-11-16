import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DELEGATES = ROOT / "source" / "Delegates"
SETTINGS = DELEGATES / "SettingsDelegates"
SETTINGS_RING = SETTINGS / "SettingsMenuDelegates"


def source(path):
    return path.read_text(encoding="utf-8")


def method(text, name, next_name=None):
    start = text.index(f"function {name}(")
    if next_name is None:
        return text[start:]
    end = text.index(f"function {next_name}(", start)
    return text[start:end]


class UiNavigationDelegateTests(unittest.TestCase):
    def test_main_view_stacks_settings_and_preserves_back_long_press(self):
        text = source(DELEGATES / "SimpleViewDelegate.mc")

        settings = method(text, "pushSettingsView", "setMenuActive")
        self.assertIn("WatchUi.pushView(new SettingsView()", settings)
        self.assertNotIn("WatchUi.switchToView", settings)

        on_back = method(text, "onBack")
        self.assertIn("return true;", on_back)
        self.assertIn("triggerBackLongPress", text)
        self.assertIn("openFeedbackMode", text)

    def test_main_screen_routes_down_to_cadence_display_not_legacy_advanced_view(self):
        app = source(ROOT / "source" / "GarminApp.mc")
        self.assertIn(
            "return [ new SimpleView(), new SimpleViewDelegate() ];",
            app,
        )

        simple = method(source(DELEGATES / "SimpleViewDelegate.mc"), "onSwipe", "showActivityControlMenu")
        self.assertIn("WatchUi.SWIPE_UP", simple)
        self.assertIn("WatchUi.SWIPE_DOWN", simple)
        self.assertIn("if (getApp().isFeedbackHidden())", simple)
        self.assertIn("new CadenceQualityView()", simple)
        self.assertIn("new CadenceQualityDelegate()", simple)
        self.assertNotIn("new AdvancedView()", simple)
        self.assertNotIn("new AdvancedViewDelegate", simple)

        delegate = source(DELEGATES / "SimpleViewDelegate.mc")
        key_release = method(delegate, "onKeyReleased", "toggleVibration")
        self.assertIn("key == WatchUi.KEY_DOWN", key_release)
        self.assertIn("if (app.isFeedbackHidden())", key_release)
        self.assertLess(
            key_release.index("if (app.isFeedbackHidden())"),
            key_release.index("new CadenceQualityView()"),
        )
        self.assertIn("new CadenceQualityView()", key_release)
        self.assertIn("new CadenceQualityDelegate()", key_release)
        self.assertIn("WatchUi.SLIDE_DOWN", key_release)
        self.assertNotIn("new AdvancedView()", key_release)

    def test_cadence_display_closes_on_second_down_or_vertical_swipe(self):
        text = source(DELEGATES / "CadenceQualityDelegate.mc")

        on_key = method(text, "onKey", "onKeyReleased")
        self.assertIn("keyEvent.getKey() == WatchUi.KEY_DOWN", on_key)
        self.assertIn("return true;", on_key)

        released = method(text, "onKeyReleased", "onSwipe")
        self.assertIn("keyEvent.getKey() == WatchUi.KEY_DOWN", released)
        self.assertIn("WatchUi.popView(WatchUi.SLIDE_UP)", released)

        swipe = method(text, "onSwipe")
        self.assertIn("WatchUi.SWIPE_UP", swipe)
        self.assertIn("WatchUi.SWIPE_DOWN", swipe)
        self.assertEqual(2, swipe.count("WatchUi.popView("))

    def test_main_view_ignores_releases_from_a_screen_that_just_closed(self):
        text = source(DELEGATES / "SimpleViewDelegate.mc")
        self.assertIn("private var _escPressed = false;", text)
        self.assertIn("private var _downPressed = false;", text)

        pressed = method(text, "onKeyPressed", "triggerBackLongPress")
        self.assertIn("_downPressed = true;", pressed)
        self.assertIn("_escPressed = true;", pressed)

        released = method(text, "onKeyReleased", "toggleVibration")
        self.assertIn("if (!_downPressed)", released)
        self.assertIn("if (!_escPressed && !_handledBackLongPress)", released)

    def test_short_back_exits_only_when_idle(self):
        text = source(DELEGATES / "SimpleViewDelegate.mc")
        short_back = method(text, "handleShortBack", "onBack")
        self.assertIn("app.isRecording() || app.isPaused() || app.isStopped()", short_back)
        self.assertIn("System.exit()", short_back)

        on_back = method(text, "onBack")
        self.assertIn("return false;", on_back)

    def test_legacy_advanced_view_can_return_to_main_if_already_stacked(self):

        advanced_text = source(DELEGATES / "AdvancedViewDelegate.mc")
        advanced = method(advanced_text, "onSwipe", "onBack")
        self.assertIn("WatchUi.popView(WatchUi.SLIDE_UP)", advanced)
        self.assertIn("WatchUi.popView(WatchUi.SLIDE_DOWN)", advanced)
        self.assertIn(
            "WatchUi.popView(WatchUi.SLIDE_DOWN)",
            method(advanced_text, "pushSimpleView"),
        )

    def test_settings_entry_is_stacked_and_back_unstacks_it(self):
        text = source(SETTINGS / "SettingsMenuDelegate.mc")

        self.assertIn("WatchUi.popView(WatchUi.SLIDE_DOWN)", method(text, "onBack", "onSelect"))
        for name, next_name in (
            ("onSelect", "onNextPage"),
            ("onNextPage", "onPreviousPage"),
        ):
            self.assertIn("WatchUi.pushView", method(text, name, next_name))
        self.assertIn("WatchUi.pushView", method(text, "onPreviousPage"))

    def test_settings_ring_replaces_cards_instead_of_growing_stack(self):
        cases = (
            ("CadenceSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage"),
            ("CadenceSettingsMenuDelegate.mc", "onPreviousPage", None),
            ("ProfileSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage"),
            ("ProfileSettingsMenuDelegate.mc", "onPreviousPage", "pushProfileMenu"),
            ("PostFeedbackSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage"),
            ("PostFeedbackSettingsMenuDelegate.mc", "onPreviousPage", None),
            ("SummarySettingsMenuDelegate.mc", "handleUp", "handleDown"),
            ("SummarySettingsMenuDelegate.mc", "handleDown", "onKey"),
            ("BarChartSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage"),
            ("BarChartSettingsMenuDelegate.mc", "onPreviousPage", "pushBarChartMenu"),
            ("ResetSettingsDelegate.mc", "handleUp", "handleDown"),
            ("ResetSettingsDelegate.mc", "handleDown", "onBack"),
        )

        for filename, name, next_name in cases:
            with self.subTest(filename=filename, method=name):
                body = method(source(SETTINGS_RING / filename), name, next_name)
                self.assertIn("WatchUi.switchToView", body)

    def test_settings_ring_has_one_consistent_order(self):
        routes = (
            ("CadenceSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage", "ProfileSettingsMenuView"),
            ("ProfileSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage", "PostFeedbackSettingsView"),
            ("PostFeedbackSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage", "BarChartSettingsMenuView"),
            ("BarChartSettingsMenuDelegate.mc", "onNextPage", "onPreviousPage", "SummarySettingsMenuView"),
            ("SummarySettingsMenuDelegate.mc", "handleDown", "onKey", "ResetSettingsView"),
            ("ResetSettingsDelegate.mc", "handleDown", "onBack", "CadenceSettingsMenuView"),
        )

        for filename, name, next_name, destination in routes:
            with self.subTest(filename=filename, direction="down"):
                body = method(source(SETTINGS_RING / filename), name, next_name)
                self.assertIn(f"new {destination}(", body)

        reverse_routes = (
            ("CadenceSettingsMenuDelegate.mc", "onPreviousPage", None, "ResetSettingsView"),
            ("ProfileSettingsMenuDelegate.mc", "onPreviousPage", "pushProfileMenu", "CadenceSettingsMenuView"),
            ("PostFeedbackSettingsMenuDelegate.mc", "onPreviousPage", None, "ProfileSettingsMenuView"),
            ("BarChartSettingsMenuDelegate.mc", "onPreviousPage", "pushBarChartMenu", "PostFeedbackSettingsView"),
            ("SummarySettingsMenuDelegate.mc", "handleUp", "handleDown", "BarChartSettingsMenuView"),
            ("ResetSettingsDelegate.mc", "handleUp", "handleDown", "SummarySettingsMenuView"),
        )

        for filename, name, next_name, destination in reverse_routes:
            with self.subTest(filename=filename, direction="up"):
                body = method(source(SETTINGS_RING / filename), name, next_name)
                self.assertIn(f"new {destination}(", body)

    def test_settings_cards_pop_back_to_settings_root(self):
        for filename in (
            "CadenceSettingsMenuDelegate.mc",
            "ProfileSettingsMenuDelegate.mc",
            "PostFeedbackSettingsMenuDelegate.mc",
            "BarChartSettingsMenuDelegate.mc",
        ):
            with self.subTest(filename=filename):
                text = source(SETTINGS_RING / filename)
                self.assertIn("WatchUi.popView(WatchUi.SLIDE_DOWN)", method(text, "onBack", "onSelect"))

        summary = source(SETTINGS_RING / "SummarySettingsMenuDelegate.mc")
        self.assertIn("WatchUi.popView(WatchUi.SLIDE_DOWN)", method(summary, "onBack", "handleUp"))


if __name__ == "__main__":
    unittest.main()

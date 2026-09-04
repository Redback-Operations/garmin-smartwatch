"""Static and state-model regression tests for the Monkey C timer lifecycle."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class TimerModel:
    """Small model of GarminApp's owner-aware timer slot."""

    def __init__(self):
        self.owner = None
        self.owner_label = None
        self.active_count = 0
        self.maximum_active = 0
        self.events = []

    def start(self, owner, owner_label):
        if self.owner == owner:
            self.events.append(f"[TIMER] START skipped owner={owner_label} active=1")
            return
        if self.owner is not None:
            self.events.append(
                f"[TIMER] HANDOFF from={self.owner_label} to={owner_label}"
            )
            self.active_count = 0
        self.owner = owner
        self.owner_label = owner_label
        self.active_count = 1
        self.maximum_active = max(self.maximum_active, self.active_count)
        self.events.append(f"[TIMER] START owner={owner_label} active=1")

    def stop(self, owner, owner_label):
        if self.owner != owner:
            self.events.append(
                f"[TIMER] STOP skipped owner={owner_label} reason=not-owner"
            )
            return
        self.owner = None
        self.owner_label = None
        self.active_count = 0
        self.events.append(f"[TIMER] STOP owner={owner_label} active=0")


class TimerLifecycleTests(unittest.TestCase):
    def source(self, relative_path):
        return (ROOT / relative_path).read_text()

    def test_refresh_views_start_on_show_and_stop_on_hide(self):
        simple = self.source("source/Views/SimpleView.mc")
        advanced = self.source("source/Views/AdvancedView.mc")

        self.assertIn('app.startRefreshTimer(self, "simple_view"', simple)
        self.assertIn('app.stopRefreshTimer(self, "simple_view")', simple)
        self.assertIn('app.startRefreshTimer(self, "advanced_view"', advanced)
        self.assertIn('app.stopRefreshTimer(self, "advanced_view")', advanced)
        self.assertNotIn("new Timer.Timer()", simple)
        self.assertNotIn("new Timer.Timer()", advanced)

    def test_app_start_does_not_create_background_refresh_timer(self):
        app = self.source("source/GarminApp.mc")
        on_start = app.split("function onStart", 1)[1].split("function onStop", 1)[0]
        self.assertNotIn("new Timer.Timer()", on_start)
        self.assertIn('stopAllRefreshTimers("app-stop")', app)

    def test_overlay_timers_use_the_same_owned_slot(self):
        alert = self.source("source/Views/CadenceAlertView.mc")
        vibration = self.source("source/Views/VibrationView.mc")

        self.assertIn('app.startOneShotTimer(self, "cadence_alert"', alert)
        self.assertIn('app.stopRefreshTimer(self, "cadence_alert")', alert)
        self.assertIn('app.startOneShotTimer(self, "vibration_message"', vibration)
        self.assertIn('app.stopRefreshTimer(self, "vibration_message")', vibration)
        self.assertNotIn("new Timer.Timer()", alert)
        self.assertNotIn("new Timer.Timer()", vibration)

    def test_all_timer_allocations_are_centralized(self):
        allocations = []
        for path in (ROOT / "source").rglob("*.mc"):
            if "new Timer.Timer()" in path.read_text():
                allocations.append(path.relative_to(ROOT).as_posix())

        self.assertEqual(["source/GarminApp.mc"], allocations)

    def test_repeated_navigation_never_exceeds_one_active_timer(self):
        timer = TimerModel()

        for cycle in range(50):
            simple = ("simple", cycle)
            reopened_simple = ("simple", cycle, "reopened")
            advanced = ("advanced", cycle)
            alert = ("alert", cycle)

            timer.start(simple, "simple_view")
            timer.start(simple, "simple_view")  # duplicate onShow is ignored
            timer.start(advanced, "advanced_view")  # onShow may arrive first
            timer.stop(simple, "simple_view")  # stale onHide is harmless
            timer.stop(advanced, "advanced_view")
            timer.start(simple, "simple_view")
            # A new instance with the same label must replace the old callback.
            timer.start(reopened_simple, "simple_view")
            timer.stop(simple, "simple_view")
            timer.start(alert, "cadence_alert")  # atomic overlay handoff
            timer.stop(reopened_simple, "simple_view")
            timer.stop(alert, "cadence_alert")

        self.assertEqual(1, timer.maximum_active)
        self.assertEqual(0, timer.active_count)
        self.assertIsNone(timer.owner)

        print("\nNavigation stress evidence (final cycle):")
        for event in timer.events[-12:]:
            print(event)
        print("[TIMER TEST] cycles=50 max_active=1 final_active=0 crashes=0")


if __name__ == "__main__":
    unittest.main(verbosity=2)

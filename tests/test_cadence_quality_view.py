import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
VIEW_PATH = ROOT / "source" / "Views" / "CadenceQualityView.mc"


class CadenceQualityViewTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.view = VIEW_PATH.read_text(encoding="utf-8")

    def test_display_uses_live_activity_metrics(self):
        self.assertIn("Activity.getActivityInfo()", self.view)
        self.assertIn("info.currentCadence", self.view)
        self.assertIn("info.currentHeartRate", self.view)
        self.assertIn("info.elapsedDistance", self.view)
        self.assertIn('format("%.2f") + " KM"', self.view)

    def test_target_score_and_range_are_dynamic(self):
        self.assertIn("app.computeLiveTimeInZonePercentage()", self.view)
        self.assertIn("app.getCadenceCount()", self.view)
        self.assertIn("app.getCalculatedMinCadence()", self.view)
        self.assertIn("app.getCalculatedMaxCadence()", self.view)
        self.assertNotIn('"82%"', self.view)
        self.assertNotIn('"148"', self.view)
        self.assertNotIn('"140"', self.view)
        self.assertNotIn('"160"', self.view)

    def test_percentage_is_available_from_first_recorded_sample(self):
        app = (ROOT / "source" / "GarminApp.mc").read_text(encoding="utf-8")
        self.assertIn("function computeLiveTimeInZonePercentage()", app)
        self.assertIn("if (_cadenceCount == 0)", app)
        self.assertIn("return computeLiveTimeInZonePercentage();", app)
        self.assertNotIn("warming up", self.view)
        self.assertIn('detailText = "start recording"', self.view)
        self.assertIn('detailText = "waiting for cadence"', self.view)

    def test_view_refreshes_and_releases_its_timer(self):
        self.assertIn("new Timer.Timer()", self.view)
        self.assertIn("method(:refreshScreen), 1000, true", self.view)
        self.assertIn("function onHide() as Void", self.view)
        self.assertIn("_refreshTimer.stop()", self.view)
        self.assertIn("_refreshTimer = null", self.view)

    def test_feedback_hidden_period_never_reveals_cadence(self):
        hidden_check = self.view.index("if (app.isFeedbackHidden())")
        draw_live = self.view.index("drawCadenceDisplay", hidden_check)
        self.assertLess(hidden_check, draw_live)
        self.assertIn("FeedbackHiddenRenderer.draw(dc, app)", self.view)

    def test_marker_and_status_follow_live_cadence(self):
        self.assertIn("cadence < targetMin", self.view)
        self.assertIn("cadence > targetMax", self.view)
        self.assertIn('statusText = "faster"', self.view)
        self.assertIn('statusText = "slower"', self.view)
        self.assertIn('statusText = "in range"', self.view)
        self.assertIn("clampedCadence", self.view)


if __name__ == "__main__":
    unittest.main()

import pathlib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]


def read(relative_path):
    return (ROOT / relative_path).read_text(encoding="utf-8")


class WorkoutSummaryPersistenceTests(unittest.TestCase):
    def test_final_metrics_are_captured_before_garmin_stops_recording(self):
        app = read("source/GarminApp.mc")
        stop_method = app[app.index("function stopRecording"):app.index("function saveSession")]

        self.assertLess(
            stop_method.index("captureActivityMetrics();"),
            stop_method.index("activitySession.stop()"),
        )

    def test_successful_save_persists_last_workout_snapshot(self):
        app = read("source/GarminApp.mc")
        save_method = app[app.index("function saveSession"):app.index("function discardSession")]

        self.assertIn("persistLastWorkoutSummary();", save_method)
        self.assertIn("PROP_LAST_SUMMARY_DURATION", app)
        self.assertIn("PROP_LAST_SUMMARY_AVG_CADENCE", app)
        self.assertIn("PROP_LAST_SUMMARY_CADENCE_SCORE", app)
        self.assertIn("PROP_LAST_SUMMARY_CALORIES", app)

    def test_settings_summary_reads_saved_workout_not_live_activity(self):
        view = read("source/Views/SettingsViews/WorkOutSummarySettingsView.mc")

        self.assertIn("app.hasLastWorkoutSummary()", view)
        self.assertIn("app.getLastSummaryDuration()", view)
        self.assertIn("app.getLastSummaryAverageCadence()", view)
        self.assertIn("app.getLastSummaryCadenceScore()", view)
        self.assertIn("app.getLastSummaryCalories()", view)
        self.assertNotIn("Activity.getActivityInfo()", view)

    def test_summary_navigation_does_not_push_a_view_during_render(self):
        view = read("source/Views/SettingsViews/SummarySettingsMenuView.mc")
        on_update = view[view.index("function onUpdate"):view.index("function openConfirmScreen")]

        self.assertNotIn("WatchUi.pushView", on_update)


if __name__ == "__main__":
    unittest.main()

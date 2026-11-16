import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(relative_path):
    return (ROOT / relative_path).read_text(encoding="utf-8")


class FeedbackModeTests(unittest.TestCase):
    def test_schedule_uses_active_recording_ticks_and_resets_per_activity(self):
        app = read("source/GarminApp.mc")
        self.assertIn("const FEEDBACK_INITIAL_VISIBLE_SECONDS = 60", app)
        self.assertIn("const FEEDBACK_HIDDEN_SECONDS = 30", app)
        self.assertRegex(
            app,
            r"function updateCadenceBarAvg\(\)[\s\S]*?"
            r"if \(_sessionState != RECORDING\)[\s\S]*?return;[\s\S]*?"
            r"updateFeedbackSession\(info\)",
        )
        self.assertGreaterEqual(app.count("resetFeedbackSession();"), 2)
        self.assertIn("if (_feedbackModeEnabled)", app)

    def test_long_back_toggles_feedback_only_before_a_run(self):
        app = read("source/GarminApp.mc")
        delegate = read("source/Delegates/SimpleViewDelegate.mc")
        status_view = read("source/Views/FeedbackModeView.mc")
        self.assertIn("function toggleFeedbackMode()", app)
        self.assertIn("if (!isIdle())", app)
        self.assertIn("app.toggleFeedbackMode()", delegate)
        self.assertIn("if (!app.isIdle())", delegate)
        self.assertIn('"ON - ready for next run"', status_view)
        self.assertIn('"OFF - normal feedback"', status_view)

    def test_hidden_samples_are_scored_and_live_cues_are_suppressed(self):
        app = read("source/GarminApp.mc")
        view = read("source/Views/SimpleView.mc")
        renderer = read("source/Views/FeedbackHiddenRenderer.mc")
        self.assertRegex(
            app,
            r"if \(_feedbackHiddenActive && cadence != null\) \{[\s\S]*?"
            r"_feedbackHiddenSampleCount\+\+",
        )
        self.assertIn("_feedbackHiddenInRangeCount++", app)
        self.assertRegex(
            app,
            r"if \(isFeedbackHidden\(\)\)[\s\S]*?"
            r"_secondsSinceLastAlert = 0;[\s\S]*?return;",
        )
        self.assertIn("drawFeedbackHiddenIndicator", view)
        self.assertIn("FeedbackHiddenRenderer.draw(dc, app)", view)
        self.assertIn('"FEEDBACK"', renderer)
        self.assertIn('"HIDDEN"', renderer)
        self.assertIn("_pendingSecondVibe = false", view)

    def test_hidden_notice_is_single_and_limited_to_four_seconds(self):
        app = read("source/GarminApp.mc")
        delegate = read("source/Delegates/SimpleViewDelegate.mc")
        cadence_view = read("source/Views/CadenceQualityView.mc")
        renderer = read("source/Views/FeedbackHiddenRenderer.mc")

        self.assertIn("const FEEDBACK_HIDDEN_NOTICE_SECONDS = 4", app)
        self.assertIn("function shouldShowFeedbackHiddenNotice()", app)
        self.assertIn("cycleSecond < FEEDBACK_HIDDEN_NOTICE_SECONDS", app)
        self.assertIn("if (app.isFeedbackHidden())", delegate)
        self.assertIn("DOWN ignored while feedback is hidden", delegate)
        self.assertIn("FeedbackHiddenRenderer.draw(dc, app)", cadence_view)
        self.assertIn("if (!app.shouldShowFeedbackHiddenNotice())", renderer)
        self.assertIn("return;", renderer)

        main_view = read("source/Views/SimpleView.mc")
        self.assertIn(
            "app.isFeedbackHidden() && app.shouldShowFeedbackHiddenNotice()",
            main_view,
        )
        self.assertIn("WatchUi.popView(WatchUi.SLIDE_IMMEDIATE)", cadence_view)

    def test_feedback_summary_precedes_existing_workout_summary(self):
        delegate = read("source/Delegates/SimpleViewDelegate.mc")
        feedback_delegate = read("source/Delegates/FeedbackSummaryDelegate.mc")
        feedback_view = read("source/Views/FeedbackSummaryView.mc")
        self.assertIn("app.hasFeedbackSummaryData()", delegate)
        self.assertIn("new FeedbackSummaryView(false)", delegate)
        self.assertIn("new SummaryView()", feedback_delegate)
        self.assertIn('"When hidden"', feedback_view)
        self.assertIn('"in target range"', feedback_view)
        self.assertIn('"Shaded = Feedback hidden"', feedback_view)
        self.assertIn("didHoldCadenceWhenHidden", feedback_view)

    def test_feedback_summary_has_compact_round_watch_layout(self):
        feedback_view = read("source/Views/FeedbackSummaryView.mc")
        self.assertIn("width < 300", feedback_view)
        self.assertIn("Graphics.FONT_NUMBER_MILD", feedback_view)
        self.assertIn("Graphics.FONT_MEDIUM", feedback_view)
        self.assertIn("dc.fillRoundedRectangle", feedback_view)
        self.assertIn("Rez.Drawables.FeedbackHeartRateIcon", feedback_view)
        self.assertIn("smallScreen ? 0.76 : 0.77", feedback_view)

    def test_feedback_graph_uses_recorded_time_and_clear_visual_layers(self):
        feedback_view = read("source/Views/FeedbackSummaryView.mc")
        self.assertIn("timeLog[i] - firstSecond", feedback_view)
        self.assertIn("Hidden-period strips sit behind", feedback_view)
        self.assertLess(
            feedback_view.index("dc.setColor(0x202020"),
            feedback_view.index("dc.setColor(0x174A2A"),
        )
        self.assertIn("dc.setPenWidth(smallScreen ? 2 : 3)", feedback_view)

    def test_post_feedback_is_persisted_and_available_from_settings(self):
        app = read("source/GarminApp.mc")
        feedback_view = read("source/Views/FeedbackSummaryView.mc")
        settings_view = read("source/Views/SettingsViews/PostFeedbackSettingsView.mc")
        settings_delegate = read(
            "source/Delegates/SettingsDelegates/SettingsMenuDelegates/"
            "PostFeedbackSettingsMenuDelegate.mc"
        )
        drawables = read("resources/drawables/drawables.xml")

        save_method = app[app.index("function saveSession"):app.index("function discardSession")]
        self.assertIn("persistFeedbackSummary();", save_method)
        self.assertIn("PROP_SAVED_FEEDBACK_AVAILABLE", app)
        self.assertIn("hasSavedFeedbackSummaryData", app)
        self.assertIn("getSavedFeedbackCadenceLog", app)
        self.assertIn("getSavedFeedbackHiddenLog", app)
        self.assertIn("getSavedFeedbackTimeLog", app)
        self.assertIn("_useSavedData", feedback_view)
        self.assertIn('"No saved feedback"', feedback_view)
        self.assertIn('"Post Feedback"', settings_view)
        self.assertIn("Rez.Drawables.PostFeedbackIcon", settings_view)
        self.assertIn("new FeedbackSummaryView(true)", settings_delegate)
        self.assertIn('id="PostFeedbackIcon"', drawables)

        stop_method = app[app.index("function stopRecording"):app.index("function saveSession")]
        self.assertLess(
            stop_method.index("captureActivityMetrics();"),
            stop_method.index("activitySession.stop()"),
        )


if __name__ == "__main__":
    unittest.main()

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Application;

class WorkOutSummarySettingsView extends WatchUi.View {

    var _avgCadence = "-- spm";
    var _duration = "00:00:00";
    var _cadenceScore = "--%";
    var _calories = "-- kcal";

    private var _timer as Timer.Timer?;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        _timer = new Timer.Timer();
        _timer.start(method(:onTimerCallback), 1000, true);
    }

    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function onTimerCallback() as Void {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        updateDisplayStrings();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        var titleY = (height * 0.25).toNumber();
        var startY = (height * 0.42).toNumber();
        var gap = (height * 0.09).toNumber(); 
        
        var leftMargin = (width * 0.15).toNumber();
        var rightMargin = (width * 0.84).toNumber();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        dc.drawText(
            centerX, 
            titleY, 
            Graphics.FONT_XTINY, 
            "Workout Summary", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        drawMetricRow(dc, leftMargin, rightMargin, startY, "Avg Cadence", _avgCadence, Graphics.COLOR_GREEN);
        drawMetricRow(dc, leftMargin, rightMargin, startY + gap, "Duration", _duration, Graphics.COLOR_WHITE);
        drawMetricRow(dc, leftMargin, rightMargin, startY + (gap * 2), "Cadence Score", _cadenceScore, Graphics.COLOR_GREEN);
        drawMetricRow(dc, leftMargin, rightMargin, startY + (gap * 3), "Calories", _calories, Graphics.COLOR_GREEN);
    }

    function drawMetricRow(dc as Dc, leftX as Number, rightX as Number, y as Number, label as String, value as String, valueColor as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            leftX, 
            y, 
            Graphics.FONT_XTINY, 
            label, 
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(valueColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            rightX, 
            y, 
            Graphics.FONT_XTINY, 
            value, 
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function updateDisplayStrings() as Void {
        var app = Application.getApp() as GarminApp;

        if (!app.hasLastWorkoutSummary()) {
            _avgCadence = "-- spm";
            _duration = "00:00:00";
            _cadenceScore = "--%";
            _calories = "-- kcal";
            return;
        }

        var duration = app.getLastSummaryDuration();
        if (duration != null) {
            var totalSeconds = duration / 1000;
            var hours = totalSeconds / 3600;
            var minutes = (totalSeconds % 3600) / 60;
            var seconds = totalSeconds % 60;
            _duration = hours.format("%02d") + ":" +
                minutes.format("%02d") + ":" + seconds.format("%02d");
        }

        var averageCadence = app.getLastSummaryAverageCadence();
        if (averageCadence != null && averageCadence >= 0) {
            _avgCadence = averageCadence.toNumber().format("%d") + " spm";
        }

        var cadenceScore = app.getLastSummaryCadenceScore();
        if (cadenceScore != null && cadenceScore >= 0) {
            _cadenceScore = cadenceScore.toNumber().format("%d") + "%";
        }

        var calories = app.getLastSummaryCalories();
        if (calories != null && calories >= 0) {
            _calories = calories.toNumber().format("%d") + " kcal";
        }
    }
}

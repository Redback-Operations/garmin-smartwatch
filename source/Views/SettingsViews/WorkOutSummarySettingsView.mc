import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Activity;

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
        var info = Activity.getActivityInfo();

        if (info != null) {
            if (info.timerTime != null) {
                var s = info.timerTime / 1000;
                _duration = ((s / 3600).format("%02d") + ":" + ((s % 3600) / 60).format("%02d") + ":" + (s % 60).format("%02d"));
            }
            if (info.averageCadence != null) {
                _avgCadence = info.averageCadence.format("%d") + " spm";
            }
            if (info.calories != null) {
                _calories = info.calories.format("%d") + " kcal";
            }
        }
    }
}
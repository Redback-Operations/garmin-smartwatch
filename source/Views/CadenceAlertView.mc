import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.System;
import Toybox.Application;

class CadenceAlertView extends WatchUi.View {

    private var _message as String;
    private var _vibrationEnabled as Boolean;
    private var _closeTimerActive as Boolean;

    function initialize(message as String, vibrationEnabled as Boolean, view as String) {
        View.initialize();
        _message = message;
        _vibrationEnabled = vibrationEnabled;
        _closeTimerActive = false;
    }

    function onShow() as Void {
        if (!_closeTimerActive) {
            _closeTimerActive = true;
            var app = Application.getApp() as GarminApp;
            app.startOneShotTimer(self, "cadence_alert", method(:dismissPopup), 3000);
        }
    }

    function onHide() as Void {
        if (_closeTimerActive) {
            _closeTimerActive = false;
            var app = Application.getApp() as GarminApp;
            app.stopRefreshTimer(self, "cadence_alert");
        }
    }

    function dismissPopup() as Void {
        _closeTimerActive = false;
        System.println("[ALERT] Cadence popup dismissed");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        // Timer at top
        var timeStr = "--:--:--";
        var info = Activity.getActivityInfo();
        if (info != null && info.timerTime != null) {
            var seconds = info.timerTime / 1000;
            var h = seconds / 3600;
            var m = (seconds % 3600) / 60;
            var s = seconds % 60;
            timeStr = h.format("%02d") + ":" + m.format("%02d") + ":" + s.format("%02d");
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            height * 0.15,
            Graphics.FONT_MEDIUM,
            timeStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Warning triangle
        drawWarningTriangle(dc, centerX, (height * 0.35).toNumber());

        // Alert message
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            height * 0.62,
            Graphics.FONT_SMALL,
            _message,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Vibration icon
        drawVibrationIcon(dc, centerX, (height * 0.80).toNumber());
    }

    function drawWarningTriangle(dc as Dc, centreX as Number, centreY as Number) as Void {
        var size = 22;
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i <= size; i++) {
            dc.drawLine(
                centreX - i,
                centreY + size - i,
                centreX + i,
                centreY + size - i
            );
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centreX,
            centreY + (size * 0.6).toNumber(),
            Graphics.FONT_SMALL,
            "!",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawVibrationIcon(dc as Dc, centreX as Number, centreY as Number) as Void {
        var radius = 14;
        if (_vibrationEnabled) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(centreX, centreY, radius);
            dc.drawCircle(centreX, centreY, radius + 5);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(centreX, centreY, radius);
            dc.drawLine(
                centreX - radius - 4,
                centreY + radius + 4,
                centreX + radius + 4,
                centreY - radius - 4
            );
        }
    }
}

class CadenceAlertDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onBack() as Boolean {
        return true;
    }
}

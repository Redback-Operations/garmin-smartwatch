import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Application;

class VibrationView extends WatchUi.View {

    private var _enabled;
    private var _closeTimerActive;

    function initialize(enabled) {
        View.initialize();
        _enabled = enabled;
        _closeTimerActive = false;
    }

    function onShow() as Void {
        if (!_closeTimerActive) {
            _closeTimerActive = true;
            var app = Application.getApp() as GarminApp;
            app.startOneShotTimer(self, "vibration_message", method(:closeMessage), 1200);
        }
    }

    function onHide() as Void {
        if (_closeTimerActive) {
            _closeTimerActive = false;
            var app = Application.getApp() as GarminApp;
            app.stopRefreshTimer(self, "vibration_message");
        }
    }

    function closeMessage() as Void {
        _closeTimerActive = false;
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);

    }

    // function onUpdate(dc as Dc) as Void {
    //     var width = dc.getWidth();
    //     var height = dc.getHeight();

    //     var text = _enabled ? "Vibration ON" : "Vibration OFF";

    //     dc.clear();
    //     dc.drawText(
    //         width / 2,
    //         height / 2,
    //         Graphics.FONT_LARGE,
    //         text,
    //         Graphics.TEXT_JUSTIFY_CENTER
    //     );
    // }
    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        var text = _enabled ? "Vibration ON" : "Vibration OFF";

        //  Full black background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        //  Text color
        if (_enabled) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }

        // Big centered text
        dc.drawText(
            width / 2,
            height / 2 - 10,
            Graphics.FONT_LARGE,
            text,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}

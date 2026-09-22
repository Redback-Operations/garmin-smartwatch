import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Timer;

class VibrationView extends WatchUi.View {

    private var _enabled;
    private var _closeTimer;

    function initialize(enabled) {
        View.initialize();
        _enabled = enabled;
    }

    function onShow() as Void {
        _closeTimer = new Timer.Timer();
        _closeTimer.start(method(:closeMessage), 1200, false); // 1.2 seconds
    }

    function onHide() as Void {
        if (_closeTimer != null) {
            _closeTimer.stop();
            _closeTimer = null;
        }
    }

    function closeMessage() as Void {
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

        var stateText = _enabled ? "ON" : "OFF";

        //  Full black background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        //  Text color
        if (_enabled) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }

        dc.drawText(width / 2, (height * 0.43).toNumber(), Graphics.FONT_MEDIUM, "Vibration", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(
            width / 2,
            (height * 0.58).toNumber(),
            Graphics.FONT_MEDIUM,
            stateText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

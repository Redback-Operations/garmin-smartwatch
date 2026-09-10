import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;

class CadenceTargetView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        var app = Application.getApp() as GarminApp;
        var targetCadence = app.getTargetCadence();
        //var targetCadence = 160;

        var centerX = width / 2;
        var titleY = (height * 0.29).toNumber();
        var valueY = (height * 0.50).toNumber();
        var unitY = (height * 0.63).toNumber();

        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            centerX,
            titleY,
            Graphics.FONT_MEDIUM,
            "Target Cadence",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, (height * 0.79).toNumber(), Graphics.FONT_XTINY, "UP/DOWN | START to save", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Cadence Number
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            centerX,
            valueY,
            Graphics.FONT_NUMBER_MILD,
            targetCadence.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Unit
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            centerX,
            unitY,
            Graphics.FONT_SMALL,
            "spm",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

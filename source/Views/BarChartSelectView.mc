import Toybox.Graphics;
import Toybox.WatchUi;

class BarChartSelectView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var app = getApp();

        //Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            (height * 0.29).toNumber(),
            Graphics.FONT_MEDIUM, "Bar Chart Length", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        
        //Value
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            (height * 0.50).toNumber(),
            Graphics.FONT_NUMBER_MILD, 
            app.getChartDuration(), 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Up arrow
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [(width * 0.22).toNumber(), (height * 0.42).toNumber()],
            [(width * 0.22).toNumber() - 9, (height * 0.47).toNumber()],
            [(width * 0.22).toNumber() + 9, (height * 0.47).toNumber()]
        ]);

        // Down arrow
        dc.fillPolygon([
            [(width * 0.22).toNumber(), (height * 0.58).toNumber()],
            [(width * 0.22).toNumber() - 9, (height * 0.53).toNumber()],
            [(width * 0.22).toNumber() + 9, (height * 0.53).toNumber()]
        ]);

        // Confirm hint
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            (height * 0.76).toNumber(),
            Graphics.FONT_XTINY, "START to confirm",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

import Toybox.Graphics;
import Toybox.WatchUi;

class BarChartSettingsMenuView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {

        // Makes screen black and clears it
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = dc.getWidth() / 2;
        var height = dc.getHeight();

        // Load and draw icon
        var icon = WatchUi.loadResource(Rez.Drawables.BarChartIcon);
        dc.drawBitmap(centerX - icon.getWidth() / 2, (height * 0.25).toNumber(), icon);

        // Draw "Bar Chart" title in white
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, (height * 0.57).toNumber(), Graphics.FONT_MEDIUM, "Line Chart", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw "tap to open" subtitle in grey
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, (height * 0.72).toNumber(), Graphics.FONT_XTINY, "START to open", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

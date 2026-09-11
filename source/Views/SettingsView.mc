import Toybox.Graphics;
import Toybox.WatchUi;

class SettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        var centerX = width / 2;
        var icon = WatchUi.loadResource(Rez.Drawables.SettingsIcon);
        var iconX = centerX - (icon.getWidth() / 2);
        var iconY = (height * 0.24).toNumber();

        dc.drawBitmap(iconX, iconY, icon);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(centerX, (height * 0.57).toNumber(), Graphics.FONT_MEDIUM, "Settings", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            centerX,
            (height * 0.72).toNumber(),
            Graphics.FONT_XTINY,
            "START to open",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

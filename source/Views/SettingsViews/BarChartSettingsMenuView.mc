import Toybox.Graphics;
import Toybox.WatchUi;

class BarChartSettingsMenuView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var icon = WatchUi.loadResource(
            dc.getWidth() < 300
                ? Rez.Drawables.BarChartIconCompact
                : Rez.Drawables.BarChartIcon
        );
        SettingsCardRenderer.draw(dc, icon, "Line Chart", "START to open");
    }
}

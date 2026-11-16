import Toybox.Graphics;
import Toybox.WatchUi;

class SettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var icon = WatchUi.loadResource(
            dc.getWidth() < 300
                ? Rez.Drawables.SettingsIconCompact
                : Rez.Drawables.SettingsIcon
        );
        SettingsCardRenderer.draw(dc, icon, "Settings", "START to open");
    }
}

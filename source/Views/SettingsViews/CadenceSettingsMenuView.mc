import Toybox.Graphics;
import Toybox.WatchUi;

class CadenceSettingsMenuView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var icon = WatchUi.loadResource(
            dc.getWidth() < 300
                ? Rez.Drawables.SetCadenceIconCompact
                : Rez.Drawables.SetCadenceIcon
        );
        SettingsCardRenderer.draw(dc, icon, "Set Cadence", "START to open");
    }
}

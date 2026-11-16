import Toybox.Graphics;
import Toybox.WatchUi;

class VibrationsOnSettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var icon = WatchUi.loadResource(
            dc.getWidth() < 300
                ? Rez.Drawables.VibrationsOnIconCompact
                : Rez.Drawables.VibrationsOnIcon
        );
        SettingsCardRenderer.draw(dc, icon, "Vibration On", "");
    }
}

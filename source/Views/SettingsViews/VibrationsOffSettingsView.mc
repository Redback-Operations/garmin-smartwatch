import Toybox.Graphics;
import Toybox.WatchUi;

class VibrationsOffSettingsView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var icon = WatchUi.loadResource(
            dc.getWidth() < 300
                ? Rez.Drawables.VibrationsOffIconCompact
                : Rez.Drawables.VibrationsOffIcon
        );
        SettingsCardRenderer.draw(dc, icon, "Vibration Off", "");
    }
}

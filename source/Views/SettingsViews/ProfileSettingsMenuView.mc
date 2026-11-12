import Toybox.Graphics;
import Toybox.WatchUi;

class ProfileSettingsMenuView extends WatchUi.View {

function initialize() {
    View.initialize();
}

function onUpdate(dc as Dc) as Void { 
        var icon = WatchUi.loadResource(
            dc.getWidth() < 300
                ? Rez.Drawables.ProfileSettingsIconCompact
                : Rez.Drawables.ProfileSettingsIcon
        );
        SettingsCardRenderer.draw(dc, icon, "Profile", "START to open");
    }
}



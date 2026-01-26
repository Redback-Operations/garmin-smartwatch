import Toybox.Lang;
import Toybox.WatchUi;

class TimeViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Long-press MENU to open settings
    function onMenu() as Boolean {
        pushSettingsView();
        return true;
    }

    // Down button to scroll to AdvancedView
    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_DOWN) {
            var advancedView = new AdvancedView();
            WatchUi.switchToView(
                advancedView,
                new AdvancedViewDelegate(advancedView),
                WatchUi.SLIDE_DOWN
            );
            return true;
        }

        if (key == WatchUi.KEY_UP) {
            return true;
        }

        return false;
    }

    // Back button - do nothing to prevent crash
    function onBack() as Boolean {
        return true;
    }
}

function pushSettingsView() as Void {
    var settingsView = new SettingsView();
    var settingsDelegate = new SettingsDelegate();
    WatchUi.pushView(settingsView, settingsDelegate, WatchUi.SLIDE_LEFT);
}


class SettingsDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }
}

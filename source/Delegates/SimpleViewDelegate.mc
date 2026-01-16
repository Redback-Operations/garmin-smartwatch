import Toybox.Lang;
import Toybox.WatchUi;

class SimpleViewDelegate extends WatchUi.BehaviorDelegate {

    private var _currentView = null;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Long-press MENU (optional settings)
    function onMenu() as Boolean {
        var menu = new WatchUi.Menu2({:resources => "menus/menu.xml"});
        WatchUi.pushView(
            new Rez.Menus.MainMenu(),
            new SelectCadenceDelegate(menu),
            WatchUi.SLIDE_BLINK
        );
        return true;
    }

    // SELECT toggles cadence monitoring
    function onSelect() as Boolean {
        var app = getApp();

        if (app.isActivityRecording()) {
            app.stopRecording();
            System.println("[UI] Cadence monitoring stopped");
        } else {
            app.startRecording();
            System.println("[UI] Cadence monitoring started");
        }

        WatchUi.requestUpdate();
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();

        // Block Garmin system menu
        if (key == WatchUi.KEY_UP) {
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            _currentView = new AdvancedView();
            WatchUi.pushView(
                _currentView,
                new AdvancedViewDelegate(_currentView),
                WatchUi.SLIDE_DOWN
            );
            return true;
        }

        return false;
    }

    function onSwipe(event as WatchUi.SwipeEvent) as Boolean {
        var direction = event.getDirection();

        if (direction == WatchUi.SWIPE_UP) {
            _currentView = new AdvancedView();
            WatchUi.pushView(
                _currentView,
                new AdvancedViewDelegate(_currentView),
                WatchUi.SLIDE_DOWN
            );
            return true;
        }

        if (direction == WatchUi.SWIPE_LEFT) {
            _currentView = new SettingsView();
            WatchUi.pushView(
                _currentView,
                new SettingsDelegate(_currentView),
                WatchUi.SLIDE_LEFT
            );
            return true;
        }

        return false;
    }

    function onBack() as Boolean {
        // Prevent accidental app exit
        return true;
    }
}

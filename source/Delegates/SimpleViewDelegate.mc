import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class SimpleViewDelegate extends WatchUi.BehaviorDelegate {

    private var _currentView = null;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Long-press MENU (optional settings)
    function onMenu() as Boolean {
        pushSettingsView();
        return true;
    }

    // SELECT toggles cadence monitoring
    function onSelect() as Boolean {
        var app = getApp();

        if (app.isActivityRecording()) {
            app.stopRecording();
            System.println("[UI] Cadence monitoring stopped");
            
            // Auto-navigate to summary screen if we have valid data
            if (app.hasValidSummaryData()) {
                System.println("[UI] Showing activity summary");
                var summaryView = new SummaryView();
                WatchUi.pushView(
                    summaryView,
                    new SummaryViewDelegate(),
                    WatchUi.SLIDE_UP
                );
            }
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
            _currentView = new TimeView();
            WatchUi.switchToView(
                _currentView,
                new TimeViewDelegate(),
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
            pushSettingsView();
            return true;
        }

        return false;
    }

    function pushSettingsView() as Void{
        var settingsMenu = new WatchUi.Menu2({ :title => "Settings" });

        settingsMenu.addItem(new WatchUi.MenuItem("Profile", null, :set_profile, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Customization", null, :cust_options, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Feedback", null, :feedback_options, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Cadence Range", null, :cadence_range, null));

        WatchUi.pushView(settingsMenu, new SettingsMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function onBack() as Boolean {
        // Back button disabled - no input
        return true;
    }
}

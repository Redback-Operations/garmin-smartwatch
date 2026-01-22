import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class AdvancedViewDelegate extends WatchUi.BehaviorDelegate { 
    
    private var _currentView = null;

    function initialize(view as AdvancedView) {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        // Create programmatic Menu2 instead of XML-based menu
        var app = Application.getApp() as GarminApp;
        var minCadence = app.getMinCadence();
        var maxCadence = app.getMaxCadence();
        
        var menu = new WatchUi.Menu2({
            :title => Lang.format("Cadence: $1$ - $2$", [minCadence, maxCadence])
        });
        
        menu.addItem(new WatchUi.MenuItem("Set Min Cadence", null, :item_set_min, null));
        menu.addItem(new WatchUi.MenuItem("Set Max Cadence", null, :item_set_max, null));
        
        WatchUi.pushView(menu, new SelectCadenceDelegate(menu), WatchUi.SLIDE_BLINK);
        
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();

        // UP button - Back to SimpleView
        if (key == WatchUi.KEY_UP) {
            WatchUi.popView(WatchUi.SLIDE_UP);
            return true;
        }

        return false;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        var direction = swipeEvent.getDirection();
        
        // Swipe DOWN - Back to SimpleView
        if (direction == WatchUi.SWIPE_DOWN) {
            System.println("[UI] Swiped down to SimpleView");
            WatchUi.popView(WatchUi.SLIDE_UP);
            return true;
        }

        // Swipe LEFT - Settings
        if (direction == WatchUi.SWIPE_LEFT) {
            pushSettingsView();
            return true;
        }

        return false;
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_BLINK);
        return true;
    }

    function pushSettingsView() as Void {
        var settingsMenu = new WatchUi.Menu2({ :title => "Settings" });
        settingsMenu.addItem(new WatchUi.MenuItem("Profile", null, :set_profile, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Customization", null, :cust_options, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Feedback", null, :feedback_options, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Cadence Range", null, :cadence_range, null));

        WatchUi.pushView(settingsMenu, new SettingsMenuDelegate(), WatchUi.SLIDE_UP);
    }
}

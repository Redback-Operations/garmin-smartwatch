import Toybox.Lang;
import Toybox.WatchUi;

class AdvancedViewDelegate extends WatchUi.BehaviorDelegate { 

    private var _homePage;

    function initialize(view as AdvancedView, homePage) {
        BehaviorDelegate.initialize();
        _homePage = homePage;
    }

    function onMenu() as Boolean {
        // Open settings menu from advanced view long press UP
        pushSettingsView();
        return true;
    }

    function onNextPage() as Boolean {
        ScreenNavigation.showHome(_homePage, true);
        return true;
    }

    function onPreviousPage() as Boolean {
        ScreenNavigation.showHome(_homePage, false);
        return true;
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        var direction = swipeEvent.getDirection();
        
        // Swipe LEFT - Settings
        if (direction == WatchUi.SWIPE_LEFT) {
            pushSettingsView();
            return true;
        }

        return false;
    }

    function onBack() as Boolean {
        ScreenNavigation.showHome(_homePage, false);
        return true;
    }

    function pushSettingsView() as Void {
        WatchUi.switchToView(new SettingsView(), new SettingsMenuDelegate(), WatchUi.SLIDE_UP);
    }
}

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

    function onNextPage() as Boolean {
        ScreenNavigation.showAdvanced(ScreenNavigation.HOME_TIME, true);
        return true;
    }

    function onPreviousPage() as Boolean {
        ScreenNavigation.showAdvanced(ScreenNavigation.HOME_TIME, false);
        return true;
    }

    function onSwipe(event as WatchUi.SwipeEvent) as Boolean {
        if (event.getDirection() == WatchUi.SWIPE_LEFT) {
            pushSettingsView();
            return true;
        }
        return false;
    }

    // Back button - do nothing to prevent crash
    function onBack() as Boolean {
        return true;
    }
    function pushSettingsView() as Void {
        WatchUi.switchToView(
            new SettingsView(),
            new SettingsMenuDelegate(),
            WatchUi.SLIDE_LEFT
        );
    }
}

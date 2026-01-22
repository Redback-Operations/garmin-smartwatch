import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class SummaryViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // SELECT or any key to dismiss and return to SimpleView
    function onSelect() as Boolean {
        System.println("[SUMMARY] Returning to main view");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    // BACK button to dismiss
    function onBack() as Boolean {
        System.println("[SUMMARY] Back pressed, returning to main view");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    // Swipe left to dismiss
    function onSwipe(event as WatchUi.SwipeEvent) as Boolean {
        var direction = event.getDirection();
        
        if (direction == WatchUi.SWIPE_LEFT || direction == WatchUi.SWIPE_DOWN) {
            System.println("[SUMMARY] Swiped to dismiss");
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }
        
        return false;
    }

    // Any key press dismisses
    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        
        // Allow any key to dismiss
        if (key == WatchUi.KEY_UP || key == WatchUi.KEY_DOWN || 
            key == WatchUi.KEY_ENTER || key == WatchUi.KEY_MENU) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }
        
        return false;
    }
}

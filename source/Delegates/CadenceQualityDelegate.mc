import Toybox.Lang;
import Toybox.WatchUi;

class CadenceQualityDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        if (keyEvent.getKey() == WatchUi.KEY_DOWN) {
            return true;
        }
        return BehaviorDelegate.onKey(keyEvent);
    }

    // DOWN again closes this display. Pop on release so the main screen
    // cannot receive that release and immediately reopen it.
    function onKeyReleased(keyEvent as WatchUi.KeyEvent) as Boolean {
        if (keyEvent.getKey() == WatchUi.KEY_DOWN) {
            WatchUi.popView(WatchUi.SLIDE_UP);
            return true;
        }
        return false;
    }

    function onSwipe(event as WatchUi.SwipeEvent) as Boolean {
        var direction = event.getDirection();

        if (direction == WatchUi.SWIPE_UP) {
            WatchUi.popView(WatchUi.SLIDE_UP);
            return true;
        }

        if (direction == WatchUi.SWIPE_DOWN) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }

        return false;
    }
}

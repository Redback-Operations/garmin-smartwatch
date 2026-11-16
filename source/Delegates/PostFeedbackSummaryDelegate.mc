import Toybox.Lang;
import Toybox.WatchUi;

class PostFeedbackSummaryDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        return closeSummary();
    }

    function onBack() as Boolean {
        return closeSummary();
    }

    function onSwipe(event as WatchUi.SwipeEvent) as Boolean {
        var direction = event.getDirection();
        if (direction == WatchUi.SWIPE_LEFT || direction == WatchUi.SWIPE_DOWN) {
            return closeSummary();
        }
        return false;
    }

    function closeSummary() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}

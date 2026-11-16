import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class PostFeedbackSettingsMenuDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onSelect() as Boolean {
        System.println("[FEEDBACK] Opening saved post-feedback summary");
        WatchUi.pushView(
            new FeedbackSummaryView(true),
            new PostFeedbackSummaryDelegate(),
            WatchUi.SLIDE_UP
        );
        return true;
    }

    function onNextPage() as Boolean {
        System.println("Down button pressed: Opening Bar Chart Settings");
        WatchUi.switchToView(
            new BarChartSettingsMenuView(),
            new BarChartSettingsMenuDelegate(),
            WatchUi.SLIDE_UP
        );
        return true;
    }

    function onPreviousPage() as Boolean {
        WatchUi.switchToView(
            new ProfileSettingsMenuView(),
            new ProfileSettingsMenuDelegate(),
            WatchUi.SLIDE_DOWN
        );
        return true;
    }
}

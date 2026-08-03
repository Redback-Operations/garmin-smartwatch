import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// WatchFaceMenuDelegate handles user interactions with the watch face view selection.
// It allows users to choose between different view options (Simple View, Time View).
// Replaces the previous Menu2InputDelegate-based implementation to be compatible with API 1.2.0.
class WatchFaceMenuDelegate extends WatchUi.BehaviorDelegate {

    // Initialize the delegate.
    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle menu item selection by the user.
    // Routes the selection to the appropriate view switching method based on the menu item ID.
    function onMenuSelect(id as Symbol) as Void {
        if (id == :simple_view) {
            System.println("Selected: Simple View");
            switchToSimpleView();
        } else if (id == :time_view) {
            System.println("Selected: Time View");
            switchToTimeView();
        }
    }

    // Handle back button press by closing the menu and returning to the previous view.
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    // Switch the current view to the Simple View by popping the menu layers and pushing the new view.
    private function switchToSimpleView() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        var view = new SimpleView();
        var delegate = new SimpleViewDelegate();
        WatchUi.pushView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }

    // Switch the current view to the Time View by popping the menu layers and pushing the new view.
    private function switchToTimeView() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        var view = new TimeView();
        var delegate = new TimeViewDelegate();
        WatchUi.pushView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}

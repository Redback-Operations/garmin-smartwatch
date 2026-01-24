import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// WatchFaceMenuDelegate handles user interactions with the watch face view selection menu.
// It allows users to choose between different view options (Simple View, Time View) and 
// manages the navigation between these views.
class WatchFaceMenuDelegate extends WatchUi.Menu2InputDelegate {

    // Initialize the delegate with the provided menu.
    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
    }

    // Handle menu item selection by the user.
    // Routes the selection to the appropriate view switching method based on the menu item ID.
    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        if (id == :simple_view) {
            System.println("Selected: Simple View");
            switchToSimpleView();
        } else if (id == :time_view) {
            System.println("Selected: Time View");
            switchToTimeView();
        }
    }

    // Handle back button press by closing the menu and returning to the previous view.
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    // Switch the current view to the Simple View by popping the menu layers and pushing the new view.
    // Pops two views to clear the menu and settings layers, then displays the Simple View.
    private function switchToSimpleView() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        var view = new SimpleView();
        var delegate = new SimpleViewDelegate();
        WatchUi.pushView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }

    // Switch the current view to the Time View by popping the menu layers and pushing the new view.
    // Pops two views to clear the menu and settings layers, then displays the Time View.
    private function switchToTimeView() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        var view = new TimeView();
        var delegate = new TimeViewDelegate();
        WatchUi.pushView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}

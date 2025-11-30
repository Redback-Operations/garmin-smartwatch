import Toybox.Lang;
import Toybox.WatchUi;

class TestingCadenceDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new TestingCadenceMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    // Handle the down button press to switch views
    function onNextPage() as Boolean {
        WatchUi.pushView(new TestingCadenceChartView(), new TestingCadenceChartDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }

    // Handle the up button press to switch views
    function onPreviousPage() as Boolean {
        WatchUi.pushView(new TestingCadenceChartView(), new TestingCadenceChartDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }

    // Handle select button press to switch views
    function onSelect() as Boolean {
        WatchUi.pushView(new TestingCadenceChartView(), new TestingCadenceChartDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }
}

// Delegate for the chart view to handle switching back
class TestingCadenceChartDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new TestingCadenceMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    // Handle button presses to pop back to main view
    function onNextPage() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onPreviousPage() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onSelect() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    // Also handle back button
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
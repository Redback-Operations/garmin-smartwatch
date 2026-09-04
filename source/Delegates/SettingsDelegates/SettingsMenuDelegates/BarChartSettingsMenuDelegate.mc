import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class BarChartSettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handles the BACK button
    function onBack() as Boolean{
        System.println("Back pressed: Returning to main view");

        WatchUi.switchToView(new SimpleView(), new SimpleViewDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }

    // Handles the SELECT/START button (or screen tap)
    function onSelect() as Boolean {
        System.println("Select button pressed: Opening bar chart settings");
        WatchUi.pushView(new BarChartSelectView(), new SelectBarChartDelegate(), WatchUi.SLIDE_LEFT);
        return true;
    }

    // Handles the DOWN button (or swipe up)
    function onNextPage() as Boolean {
        ScreenNavigation.showNextSettingsPage(ScreenNavigation.SETTINGS_BAR_CHART);
        return true; 
    }

    // Handles the UP button (or swipe down)
    function onPreviousPage() as Boolean {
        ScreenNavigation.showPreviousSettingsPage(ScreenNavigation.SETTINGS_BAR_CHART);
        return true; 
    }


}

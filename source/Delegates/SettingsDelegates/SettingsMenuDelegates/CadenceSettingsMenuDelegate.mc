
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;


class CadenceSettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handles the BACK button
    function onBack() as Boolean {

        System.println("Back pressed: Returning to main view");

        WatchUi.switchToView(
            new SimpleView(),
            new SimpleViewDelegate(),
            WatchUi.SLIDE_DOWN
        );

        return true;
    }

    // Handles the SELECT/START button
    function onSelect() as Boolean {

        System.println("Select pressed: Opening CadenceTargetView");

        WatchUi.pushView(
            new CadenceTargetView(),
            new CadenceTargetDelegate(),
            WatchUi.SLIDE_UP
        );

        return true;
    }

    // Handles the DOWN button
    function onNextPage() as Boolean {
        ScreenNavigation.showNextSettingsPage(ScreenNavigation.SETTINGS_CADENCE);
        return true; 
    }

    // Handles the UP button
    function onPreviousPage() as Boolean {
        ScreenNavigation.showPreviousSettingsPage(ScreenNavigation.SETTINGS_CADENCE);
        return true; 
    }
}

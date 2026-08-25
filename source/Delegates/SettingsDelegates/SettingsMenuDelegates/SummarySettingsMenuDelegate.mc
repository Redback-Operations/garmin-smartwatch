import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SummarySettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handles the BACK button
    function onBack() as Boolean {
        System.println("Back pressed: Returning to main view");

        WatchUi.switchToView(new SimpleView(), new SimpleViewDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }

    // Handles the SELECT/START button (or screen tap)
    function onSelect() as Boolean {
        System.println("Select/Tap pressed: opening summary view preference");

        var promptView = new SummaryPromptView();
        WatchUi.pushView(
            promptView,
            new SummaryPromptDelegate(promptView),
            WatchUi.SLIDE_UP
        );

        return true;
    }

    // Handles the DOWN button (or swipe up)
    function onNextPage() as Boolean {
        ScreenNavigation.showNextSettingsPage(ScreenNavigation.SETTINGS_SUMMARY);
        return true; 
    }

    // Handles the UP button (or swipe down)
    function onPreviousPage() as Boolean {
        ScreenNavigation.showPreviousSettingsPage(ScreenNavigation.SETTINGS_SUMMARY);
        return true; 
    }

}

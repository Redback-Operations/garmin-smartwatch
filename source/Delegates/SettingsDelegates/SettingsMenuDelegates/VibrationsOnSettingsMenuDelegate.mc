import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class VibrationsOnSettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        System.println("Back pressed: Returning to main view");

        WatchUi.pushView(
            new SimpleView(),
            new SimpleViewDelegate(),
            WatchUi.SLIDE_DOWN
        );

        return true;
    }

    function onSelect() {
        System.println("Select/Tap pressed: Vibrations Enabled");

        var app = Application.getApp() as GarminApp;


        app.setVibrationEnabled(true);
        app.triggerHapticFeedback();
        return true;
    }

    // Handles the DOWN button (or swipe up)
    function onNextPage() as Boolean {
        System.println("Down button pressed: Opening Bar Chart Settings");
        
        WatchUi.switchToView(
            new VibrationsOffSettingsView(),
            new VibrationsOffSettingsMenuDelegate(),
            WatchUi.SLIDE_UP);
        
        return true; 
    }

    // Handles the UP button (or swipe down)
    function onPreviousPage() {
        System.println("Up button pressed: Opening Reset Settings");
        
        var resetView = new ResetSettingsView();

        WatchUi.pushView(
            resetView,
            new ResetSettingsDelegate(resetView),
            WatchUi.SLIDE_DOWN
        );

        return true;
    }
}

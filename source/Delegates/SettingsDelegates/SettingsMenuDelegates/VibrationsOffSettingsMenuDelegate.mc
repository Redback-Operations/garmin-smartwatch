import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class VibrationsOffSettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    private var _hapticTimer;
    
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
        System.println("Select/Tap pressed: Vibrations Disabled");
        var app = Application.getApp() as GarminApp;

        app.setVibrationEnabled(false);

        var currentHaptic = app.getHaptic();

        playHighHaptic();

        _hapticTimer = new Timer.Timer();
        _hapticTimer.start(method(:playHighHaptic), 1000, false);

        app.setHaptic(currentHaptic);
        return true;
    }

    function playHighHaptic() as Void {
        var app = Application.getApp() as GarminApp;

        app.setHaptic("high");
        app.triggerHapticFeedback();

        _hapticTimer = null;
    }

    // Handles the DOWN button (or swipe up)
    function onNextPage() as Boolean {
        System.println("Down button pressed: Opening Cadence Settings");
        
        WatchUi.switchToView(
            new CadenceSettingsMenuView(),
            new CadenceSettingsMenuDelegate(),
            WatchUi.SLIDE_UP);
        
        return true; 
    }

    // Handles the UP button (or swipe down)
    function onPreviousPage() {
        System.println("Up button pressed: Opening Vibrations On Settings");
        
        WatchUi.pushView(
            new VibrationsOnSettingsView(),
            new VibrationsOnSettingsMenuDelegate(),
            WatchUi.SLIDE_DOWN
        );

        return true;
    }
}

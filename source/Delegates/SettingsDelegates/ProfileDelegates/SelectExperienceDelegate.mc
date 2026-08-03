import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectExperienceDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle an experience level item id selected from the custom menu
    function onMenuSelect(id as Symbol) as Void {
        var app = Application.getApp() as GarminApp;

        if (id == :exp_beginner) { app._experienceLvl = 1.06; }
        else if (id == :exp_intermediate) { app._experienceLvl = 1.04; }
        else if (id == :exp_advanced) { app._experienceLvl = 1.02; }

        System.println("Experience updated to: " + app._experienceLvl);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    // Handle BACK
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectGenderDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle a gender item id selected from the custom menu
    function onMenuSelect(id as Symbol) as Void {
        var app = Application.getApp() as GarminApp;

        if (id == :user_male) { app._userGender = 0; }
        else if (id == :user_female) { app._userGender = 1; }
        else { app._userGender = 2; }

        System.println("Gender updated to: " + app._userGender);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    // Handle BACK
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

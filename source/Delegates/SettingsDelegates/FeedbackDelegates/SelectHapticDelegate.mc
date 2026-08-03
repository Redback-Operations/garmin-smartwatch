import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectHapticDelegate extends WatchUi.BehaviorDelegate { 

    var app = Application.getApp() as GarminApp;
    //var haptic = app.getHaptic();
    var haptic = "low";// make sure to change to above!! - after feature has been added

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle a haptic item id selected from the custom menu
    function onMenuSelect(id as Symbol) as Void {
        if (id == :haptic_low){
            System.println("Haptic Feedback: LOW");
            //app.setHaptic("low");
        } 
        else if (id == :haptic_med){
            System.println("Haptic Feedback: MEDIUM");
            //app.setUserHaptic("med");
        } 
        else if (id == :haptic_high){
            System.println("Haptic Feedback: HIGH");
            //app.setUserHaptic("high");
        } else {System.println("ERROR");}

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    // Returns back one menu
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
        return true;
    }
}

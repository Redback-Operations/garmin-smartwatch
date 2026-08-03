import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectAudibleDelegate extends WatchUi.BehaviorDelegate { 

    var app = Application.getApp() as GarminApp;
    //var Audible = app.getAudible();
    var Audible = "low";// make sure to change to above!! - after feature has been added

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle an audible item id selected from the custom menu
    function onMenuSelect(id as Symbol) as Void {
        if (id == :audible_low){
            System.println("Audible Feedback: LOW");
            //app.setAudible("low");
        } 
        else if (id == :audible_med){
            System.println("Audible Feedback: MEDIUM");
            //app.setUserAudible("med");
        } 
        else if (id == :audible_high){
            System.println("Audible Feedback: HIGH");
            //app.setUserAudible("high");
        } else {System.println("ERROR");}

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    // Returns back one menu
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
        return true;
    }
}

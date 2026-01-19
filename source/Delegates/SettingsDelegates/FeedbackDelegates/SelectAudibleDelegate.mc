import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectAudibleDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;
    var app = Application.getApp() as GarminApp;
    //var Audible = app.getAudible();
    var Audible = "low";// make sure to change to above!! - after feature has been added

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;

        var newTitle = Lang.format("Audible: $1$", [Audible]);
        
        // This updates the UI when the cadence is changed
        _menu.setTitle(newTitle);
    }

    function onSelect(item) as Void {

        var id = item.getId();
        
        //Try to change cadence range based off menu selection
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

    function onMenuItem(item as Symbol) as Void {}

    // Returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
    }
}
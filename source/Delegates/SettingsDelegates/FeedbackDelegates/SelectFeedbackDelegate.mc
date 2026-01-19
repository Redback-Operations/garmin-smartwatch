import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectFeedbackDelegate extends WatchUi.Menu2InputDelegate { 

    //private var _menu as WatchUi.Menu2;
    var app = Application.getApp() as GarminApp;
    //var experienceLvl = app.getUserGender();
    var gender = "Other";// make sure to change to above!!

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        //_menu = menu;
    }

    function onSelect(item) as Void {

        var id = item.getId();
        
        //Try to change cadence range based off menu selection
        if (id == :haptic_feedback){
            System.println("Haptic menu selected");
            pushHapticSettings();
        } 
        else if (id == :audible_feedback){
            System.println("Audible menu selected");
            pushAudibleSettings();
        } else {System.println("ERROR");}

    }

    function pushHapticSettings() as Void{
        var menu = new WatchUi.Menu2({
            :title => "Haptic Settings"
        });
        //temp items since feedback has not yet been implemented
        menu.addItem(new WatchUi.MenuItem("Low", null, :haptic_low, null));
        menu.addItem(new WatchUi.MenuItem("Medium", null, :haptic_med, null));
        menu.addItem(new WatchUi.MenuItem("High", null, :haptic_high, null));

        //pushes the view to the screen with the relevent delegate
        WatchUi.pushView(menu, new SelectHapticDelegate(menu), WatchUi.SLIDE_LEFT);
    }

    function pushAudibleSettings() as Void{
                var menu = new WatchUi.Menu2({
            :title => "Audible Settings"
        });

        menu.addItem(new WatchUi.MenuItem("Low", null, :audible_low, null));
        menu.addItem(new WatchUi.MenuItem("Medium", null, :audible_med, null));
        menu.addItem(new WatchUi.MenuItem("High", null, :audible_high, null));

        //pushes the view to the screen with the relevent delegate
        WatchUi.pushView(menu, new SelectAudibleDelegate(menu), WatchUi.SLIDE_LEFT);
    }

    function onMenuItem(item as Symbol) as Void {}

    // Returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
    }
}
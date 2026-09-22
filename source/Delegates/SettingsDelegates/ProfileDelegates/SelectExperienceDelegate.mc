import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectExperienceDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;
    var app = Application.getApp() as GarminApp;
    //var experienceLvl = app.getExperienceLvl();
    var experienceLvl = 1.06;// make sure to change to above!!

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;

        // 1. Pull the current value from the "brain" (GarminApp)
        var currentExp = app._experienceLvl;
        var expLabel = "Beginner";

        // 2. LOGIC: Match the saved number to the Menu Row (Index)
        // Beginner is Row 0, Intermediate is Row 1, Advanced is Row 2
        if (currentExp == 1.06) {
            expLabel = "Beginner";
            _menu.setFocus(0); 
        } else if (currentExp == 1.04) {
            expLabel = "Intermediate";
            _menu.setFocus(1); 
        } else if (currentExp == 1.02) {
            expLabel = "Advanced";
            _menu.setFocus(2); 
        }

        // 3. Apply the readable label to the title
        _menu.setTitle("Exp: " + expLabel);

    }

    function onSelect(item) {
        var id = item.getId();
        var app = Application.getApp() as GarminApp;

        if (id == :exp_beginner) { app.setExperienceLvl(1.06); }
        else if (id == :exp_intermediate) { app.setExperienceLvl(1.04); }
        else if (id == :exp_advanced) { app.setExperienceLvl(1.02); }

        System.println("Experience updated to: " + app._experienceLvl);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        //return true;
    }

    function onMenuItem(item as Symbol) as Void {}

    // Returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
        //return true;
    }
}

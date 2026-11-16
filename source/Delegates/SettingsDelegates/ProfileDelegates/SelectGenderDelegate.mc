import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectGenderDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;
    var app = Application.getApp() as GarminApp;
    //var experienceLvl = app.getUserGender();
    var gender = "Other";// make sure to change to above!!

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;

        var currentGender = app._userGender;
        var genderLabel = "Other";

        if (currentGender == 0) {
            genderLabel = "Male";
            // Focus the first item
            _menu.setFocus(0); 
        } else if (currentGender == 1) {
            genderLabel = "Female";
            // Focus the second item
            _menu.setFocus(1); 
        } else {
            _menu.setFocus(2);
        }

        _menu.setTitle("Gender: " + genderLabel);
    }

    function onSelect(item) {
        System.println("DEBUG: I clicked on " + item.getId());
        var id = item.getId();
        var app = Application.getApp() as GarminApp;

        if (id == :user_male) { app.setUserGender(0); }
        else if (id == :user_female) { app.setUserGender(1); }
        else { app.setUserGender(2); }

        System.println("Gender updated to: " + app._userGender);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        //return true;
    }

    function onMenuItem(item as Symbol) as Void {}

    // Returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
    }
}

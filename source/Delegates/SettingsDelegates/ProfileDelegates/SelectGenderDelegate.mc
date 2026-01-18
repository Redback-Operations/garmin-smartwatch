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

                // need if statements to display experiencelvl string instead of float values
        var newTitle = Lang.format("Gender: $1$", [gender]);
        
        // This updates the UI when the cadence is changed
        _menu.setTitle(newTitle);
    }

    function onSelect(item) as Void {

        var id = item.getId();
        
        //Try to change cadence range based off menu selection
        if (id == :user_male){
            System.println("User Gender: Male");
            //app.setUserGender("Male");
        } 
        else if (id == :user_female){
            System.println("User Gender: Female");
            //app.setUserGender("Female");
        } 
        else if (id == :user_other){
            System.println("User Gender: Other");
            //app.setUserGender("Other");
        } else {System.println("ERROR");}

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onMenuItem(item as Symbol) as Void {}

    // Returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
    }
}
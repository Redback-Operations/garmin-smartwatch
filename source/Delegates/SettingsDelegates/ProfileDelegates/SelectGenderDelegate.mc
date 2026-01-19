import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectGenderDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;
    var app = Application.getApp() as GarminApp;
    var gender = app.getUserGender();

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
        
        //Try to change user gender based off menu selection
        if (id == :user_male){
            app.setUserGender(GarminApp.Male);
            System.println("User Gender: Male");
        } 
        else if (id == :user_female){
            app.setUserGender(GarminApp.Female);
            System.println("User Gender: Female");
        } 
        else if (id == :user_other){
            app.setUserGender(GarminApp.Other);
            System.println("User Gender: Other");
        } else {System.println("ERROR");}

        app.idealCadenceCalculator();

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onMenuItem(item as Symbol) as Void {}

    // Returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
    }
}
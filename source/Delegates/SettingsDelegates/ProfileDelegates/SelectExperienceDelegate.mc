import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectExperienceDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;
    var app = Application.getApp() as GarminApp;
    var experienceLvl = app.getExperienceLvl();
    var experienceLvlString = "NULL";

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;

        if (experienceLvl == GarminApp.Beginner){
            experienceLvlString = "Beginner";
        } else if (experienceLvl == GarminApp.Intermediate){
            experienceLvlString = "Intermediate";
        } else if (experienceLvl == GarminApp.Advanced){
            experienceLvlString = "Advanced";
        }
        var newTitle = Lang.format("Experience: $1$", [experienceLvlString]);
        
        // This updates the UI when the experience level is changed
        _menu.setTitle(newTitle);
    }

    function onSelect(item) as Void {

        var id = item.getId();
        
        //Try to change user experience lvl based off menu selection
        if (id == :exp_beginner){
            System.println("User ExperienceLvl: Beginner");
            app.setExperienceLvl(GarminApp.Beginner);
        } 
        else if (id == :exp_intermediate){
            System.println("User ExperienceLvl: Intermediate");
            app.setExperienceLvl(GarminApp.Intermediate);
        } 
        else if (id == :exp_advanced){
            System.println("User ExperienceLvl: Advanced");
            app.setExperienceLvl(GarminApp.Advanced);
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
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectCadenceDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;
    }

    function onSelect(item) as Void {
    }


    function onMenuItem(item as Symbol) as Void {
        //var id = item.getId();
        var app = Application.getApp() as GarminApp;
        var currentMin = app.getMinCadence();
        var currentMax = app.getMaxCadence();


        //Try to change cadence range based off menu selection
        if (item == :item_inc_min){
            var v = currentMin + 5;
            if (v < currentMax){
                app.setMinCadence(v);
                System.println("Cadence Min + 5 : " + v.toString());
                //WatchUi.popView(WatchUi.SLIDE_RIGHT); 
            } else {System.println("Cadence Min cannot be more than Cadence Max");}
        } 
        else if (item == :item_dec_min){
            var v = currentMin - 5;
            if (v > 0){
                app.setMinCadence(v);
                System.println("Cadence Min - 5 : " + v.toString());
                //WatchUi.popView(WatchUi.SLIDE_RIGHT); 
            } else {System.println("Cadence cannot be negative");}
        } 
        else if (item == :item_inc_max){
            // no upper bounds yet
            var v = currentMax + 5;
            app.setMaxCadence(v);
            System.println("Cadence Max + 5 : " + v.toString());
            //WatchUi.popView(WatchUi.SLIDE_RIGHT); 
        } 
        else if (item == :item_dec_max){
            var v = currentMax - 5;
            if (v > currentMin){
                app.setMaxCadence(v);
                System.println("Cadence Max - 5 : " + v.toString());
                //WatchUi.popView(WatchUi.SLIDE_RIGHT); 
            } else {System.println("Cadence Max cannot be less than Cadence Min");}
        }

        var newMin = app.getMinCadence();
        var newMax = app.getMaxCadence();
        
        var newTitle = Lang.format("Cadence: $1$ - $2$", [newMin, newMax]);
        
        // This updates the UI immediately
        _menu.setTitle(newTitle);
    }

    // Returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_BLINK); 
    }
}
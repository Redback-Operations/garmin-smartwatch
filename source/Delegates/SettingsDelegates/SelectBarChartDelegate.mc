import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

class SelectBarChartSettingsDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;
        
        _menu.setTitle("Select Duration"); 
    }

    function onSelect(item as WatchUi.MenuItem) as Void {

        var id = item.getId();

        //displays the menu for the selected item
        if (id == :minutes_15){
            System.println("[15 Minutes Selected]");
            updateDuration(15);
        } 
        else if (id == :minutes_30){
            System.println("[30 Minutes Selected]");
            updateDuration(30);
        } 
        else if (id == :minutes_60){
            System.println("[1 Hours Selected]");
            updateDuration(60);
        } 
        else if (id == :minutes_120){
            System.println("[2 Hours Selected]");
            updateDuration(120);
        }
    }

    function onMenuItem(item as Symbol) as Void {}

    // Returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
    }

    function updateDuration(value as Number){
        var app = Application.getApp() as GarminApp;

        var duration_value = 0;

        switch (value) {
            case 15:
                duration_value = 5;
                app.setChartDuration(duration_value);
                break;
            case 30:
                duration_value = 10;
                app.setChartDuration(duration_value);
                break;
            case 60:
                duration_value = 20;
                app.setChartDuration(duration_value);
                break;
            case 120:
                duration_value = 40;
                app.setChartDuration(duration_value);
                break;
            default:
                break;
        }
    }

}
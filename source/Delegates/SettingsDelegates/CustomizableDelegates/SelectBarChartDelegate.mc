import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectBarChartDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;
    var app = getApp();
    var chartDuration = app.getChartDuration();

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;
        var newTitle = Lang.format("Chart: $1$", [chartDuration]);
        
        // This updates the UI when the chart duration is changed
        _menu.setTitle(newTitle);
    }

    function onSelect(item) as Void {

        var id = item.getId();

        //Try to change cadence range based off menu selection
        if (id == :chart_15m){
            app.setChartDuration(GarminApp.FifteenminChart);
        }
        else if (id == :chart_30m){
            app.setChartDuration(GarminApp.ThirtyminChart);
        }
        else if (id == :chart_1h){
            app.setChartDuration(GarminApp.OneHourChart);
        }
        else if (id == :chart_2h){
            app.setChartDuration(GarminApp.TwoHourChart);
        }
        else {System.println("ERROR");}

        WatchUi.popView(WatchUi.SLIDE_RIGHT); 

    }

    function onMenuItem(item as Symbol) as Void {}

    //returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
    }
}
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectBarChartDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;
    var app = Application.getApp() as GarminApp;
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
            app.setChartDuration("FifteenminChart");
            System.println("Chart Duration: Fifteenmin");
        }
        else if (id == :chart_30m){
            app.setChartDuration("ThirtyminChart");
            System.println("Chart Duration: Thirtymin");
        }
        else if (id == :chart_1h){
            app.setChartDuration("OneHourChart");
            System.println("Chart Duration: OneHour");
        }
        else if (id == :chart_2h){
            app.setChartDuration("TwoHourChart");
            System.println("Chart Duration: TwoHour");
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
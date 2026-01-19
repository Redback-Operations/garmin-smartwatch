import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectCutomizableDelegate extends WatchUi.Menu2InputDelegate { 

    //private var _menu as WatchUi.Menu2;

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        //_menu = menu;
    }

    function onSelect(item) as Void {

        var id = item.getId();

        //Add if more customizable options are added
        if (id == :cust_bar_chart){
            pushBarChartMenu();
        } 
        else {System.println("ERROR");}

    }

    function pushBarChartMenu() as Void {
        var menu = new WatchUi.Menu2({
            :title => "Bar Chart Length:"
        });

        menu.addItem(new WatchUi.MenuItem("15 Minute", null, :chart_15m, null));
        menu.addItem(new WatchUi.MenuItem("30 Minute", null, :chart_30m, null));
        menu.addItem(new WatchUi.MenuItem("1 Hour", null, :chart_1h, null));
        menu.addItem(new WatchUi.MenuItem("2 Hour", null, :chart_2h, null));

        //pushes the view to the screen with the relevent delegate
        WatchUi.pushView(menu, new SelectBarChartDelegate(menu), WatchUi.SLIDE_LEFT);
    }

    function onMenuItem(item as Symbol) as Void {}

    //returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
    }
}
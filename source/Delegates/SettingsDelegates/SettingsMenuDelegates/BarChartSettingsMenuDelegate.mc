import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class BarChartSettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handles the BACK button
    function onBack() as Boolean{
        System.println("Back pressed: Returning to main view");

        WatchUi.switchToView(new SimpleView(), new SimpleViewDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }

    // Handles the SELECT/START button (or screen tap)
    function onSelect() as Boolean {
        System.println("Select button pressed: Opening Bar chart settings");

        pushBarChartMenu();
        return true;
    }



    // Handles the DOWN button (or swipe up)
    function onNextPage() as Boolean {
        System.println("Down button pressed: Opening Reset Settings");

        var resetView = new ResetSettingsView();
        
        // Push the reset settings view
        WatchUi.pushView(
            resetView,
            new ResetSettingsDelegate(resetView),
            WatchUi.SLIDE_UP
        );
        
        return true; 
    }

    // Handles the UP button (or swipe down)
    function onPreviousPage() as Boolean {
        System.println("Up button pressed: Opening Summary Settings");
        
        // Push the Summary Settings view
        var summary = new SummarySettingsMenuView();
        
        WatchUi.switchToView(
            summary,
            new SummarySettingsMenuDelegate(summary),
            WatchUi.SLIDE_DOWN);
        
        return true; 
    }


    function pushBarChartMenu() as Void{
        //creates the secondary menu and sets title
        var barChartMenu = new WatchUi.Menu2({
            :title => "Current Duration"
        });

        //creates the new menu items
        barChartMenu.addItem(new WatchUi.MenuItem("15 Minutes", null, :minutes_15, null));
        barChartMenu.addItem(new WatchUi.MenuItem("30 Minutes", null, :minutes_30, null));
        barChartMenu.addItem(new WatchUi.MenuItem("1 Hours", null, :minutes_60, null));
        barChartMenu.addItem(new WatchUi.MenuItem("2 Hours", null, :minutes_120, null));

        //pushes the view to the screen with the relevant delegate
        WatchUi.pushView(barChartMenu, new SelectBarChartSettingsDelegate(barChartMenu), WatchUi.SLIDE_LEFT);

    }

}

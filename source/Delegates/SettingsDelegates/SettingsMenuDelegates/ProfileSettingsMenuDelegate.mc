import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class ProfileSettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handles the BACK button
    function onBack() as Boolean {
        System.println("Back pressed: Returning to main view");

        WatchUi.switchToView(new SimpleView(), new SimpleViewDelegate(), WatchUi.SLIDE_DOWN);
        return true;
    }

    // Handles the SELECT/START button (or screen tap)
    function onSelect() as Boolean {
        System.println("Select/Tap pressed: toggle summary on/off   ");
        
        // Goes to profile settings
        pushProfileMenu();
        return true;
    }

    // Handles the DOWN button (or swipe up)
    function onNextPage() as Boolean {
        System.println("Down button pressed: Opening Summary Settings");
        
        // Push the cadence settings view
            var summary = new SummarySettingsMenuView();
        
        WatchUi.switchToView(
            summary,
            new SummarySettingsMenuDelegate(summary),
            WatchUi.SLIDE_UP);
        
        return true; 
    }

    // Handles the UP button (or swipe down)
    function onPreviousPage() as Boolean {
        System.println("Up button pressed: Opening Cadence Settings");
        
        // Push the Candice settings view
        WatchUi.switchToView(
            new CadenceSettingsMenuView(),
            new CadenceSettingsMenuDelegate(),
            WatchUi.SLIDE_DOWN);
                
        return true; 
    }

    function pushProfileMenu() as Void{

        //creates the secondary menu and sets title
        var menu = new WatchUi.Menu2({
            :title => "Profile Options"
        });

        //creates the new menu items
        menu.addItem(new WatchUi.MenuItem("Height", null, :profile_height, null));
        menu.addItem(new WatchUi.MenuItem("Speed", null, :profile_speed, null));
        menu.addItem(new WatchUi.MenuItem("Experience level", null, :profile_experience, null));
        menu.addItem(new WatchUi.MenuItem("Gender", null, :profile_gender, null));

        //pushes the view to the screen with the relevent delegate
        WatchUi.pushView(menu, new SelectProfileDelegate(menu), WatchUi.SLIDE_LEFT);

    }
}

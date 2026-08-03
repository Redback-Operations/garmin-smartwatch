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
        System.println("Down button pressed");
        
        // Push the cadence settings view
        
        WatchUi.switchToView(new CadenceSettingsMenuView(), new CadenceSettingsMenuDelegate(), WatchUi.SLIDE_UP);
        
        return true; 
    }

    // Handles the UP button (or swipe down)
    function onPreviousPage() as Boolean {
        System.println("Up button pressed");
        
        // Push the profile settings view
        WatchUi.switchToView(new SummarySettingsMenuView(), new SummarySettingsMenuDelegate(), WatchUi.SLIDE_DOWN);
        
        
        return true; 
    }

function pushProfileMenu() as Void{

        //creates the secondary menu and sets title
        var items = [
            { :label => "Height",       :id => :profile_height },
            { :label => "Speed",        :id => :profile_speed },
            { :label => "Experience level", :id => :profile_experience },
            { :label => "Gender",       :id => :profile_gender }
        ];

        //pushes the view to the screen with the relevant delegate
        var menu = new CustomMenuView("Profile Options", items, method(:onProfileMenuItem), method(:onProfileMenuBack), "UP/DOWN select, START confirm");
        WatchUi.pushView(menu, new CustomMenuDelegate(menu), WatchUi.SLIDE_LEFT);
    }

    // Callback for profile menu item selection (replaces SelectProfileDelegate Menu2)
    function onProfileMenuItem(id as Symbol) as Void {
        var profile = new SelectProfileDelegate();
        profile.onMenuSelect(id);
    }

    // Callback for profile menu BACK
    function onProfileMenuBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

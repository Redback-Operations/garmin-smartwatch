import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

//this Delegate handels the menu items and creates the menus for each item
class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate { 

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    //triggers when user selects a menu option
    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        
        //pushes next menu view based on selection
        if (id == :set_profile) {
            System.println("Selected: Set Profile");
            //function to push next view
            pushProfileMenu();
        } 
        else if (id == :cust_options) {
            System.println("Selected: Customizable Options");
            pushCustMenu();
        }
        else if (id == :feedback_options) {
            System.println("Selected: Feedback Options");
            pushFeedbackMenu();
        }
        else if (id == :cadence_range) {
            pushCadenceMenu(); 
        }
    }

    //allows user to go back from the menu view
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
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

    function pushCustMenu() as Void{

        var menu = new WatchUi.Menu2({
            :title => "Customization Options"
        });

        menu.addItem(new WatchUi.MenuItem("Bar Chart", null, :cust_bar_chart, null));

        WatchUi.pushView(menu, new SelectProfileDelegate(menu), WatchUi.SLIDE_LEFT);

    }

    function pushFeedbackMenu() as Void{
        
        var menu = new WatchUi.Menu2({
            :title => "Feedback Options"
        });

        menu.addItem(new WatchUi.MenuItem("Haptic Feedback", null, :profile_height, null));
        menu.addItem(new WatchUi.MenuItem("Audiable Feedback", null, :profile_speed, null));

        WatchUi.pushView(menu, new SelectProfileDelegate(menu), WatchUi.SLIDE_LEFT);
    }

    function pushCadenceMenu() as Void {

        //sets the cadence variables to the global app variable to be used within the title
        var app = Application.getApp() as GarminApp;
        var minCadence = app.getMinCadence();
        var maxCadence = app.getMaxCadence();

        var menu = new WatchUi.Menu2({
            :title => Lang.format("Cadence: $1$ - $2$", [minCadence, maxCadence])
        });

        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_inc_min), null, :item_inc_min, null));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_dec_min), null, :item_dec_min, null));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_inc_max), null, :item_inc_max, null));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_dec_max), null, :item_dec_max, null));

        WatchUi.pushView(menu, new SelectCadenceDelegate(menu), WatchUi.SLIDE_LEFT);
    }
}
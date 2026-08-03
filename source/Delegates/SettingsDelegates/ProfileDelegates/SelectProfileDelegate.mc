import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

class SelectProfileDelegate extends WatchUi.BehaviorDelegate { 

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle a menu item id selected from the profile options custom menu
    function onMenuSelect(id as Symbol) as Void {
        if (id == :profile_height){
            heightPicker();
        } 
        else if (id == :profile_speed){
            speedPicker();
        } 
        else if (id == :profile_experience){
            experienceMenu();
        } 
        else if (id == :profile_gender){
            genderMenu();
        }
    }

    function heightPicker() as Void {
        var app = Application.getApp();
        var currentHeight = app.getUserHeight();

        var factory = new ProfilePickerFactory(100, 250, 1, {:label=>" cm"});

        var picker = new WatchUi.Picker({
            :title => new WatchUi.Text({:text=>"Set Height", :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE}),
            :pattern => [factory],
            :defaults => [factory.getIndex(currentHeight)]
        });

        WatchUi.pushView(picker, new ProfilePickerDelegate(:prof_height), WatchUi.SLIDE_LEFT);
    }

    function speedPicker() as Void {
        // 1. Get the real app instance and the saved speed
        var app = Application.getApp() as GarminApp;
        var currentSpeed = app._userSpeed;

        // 2. Safety Check: If the app just installed and storage is empty
        if (currentSpeed == null) { 
            currentSpeed = 10; 
        }

        // 3. Initialize the factory with your range (5 to 30)
        var factory = new ProfilePickerFactory(5, 30, 1, {:label=>" km/h"});

        var picker = new WatchUi.Picker({
            :title => new WatchUi.Text({
                :text=>"Set Speed", 
                :locX=>WatchUi.LAYOUT_HALIGN_CENTER, 
                :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, 
                :color=>Graphics.COLOR_WHITE
            }),
            :pattern => [factory],
            :defaults => [factory.getIndex(currentSpeed)]
        });

        WatchUi.pushView(picker, new ProfilePickerDelegate(:prof_speed), WatchUi.SLIDE_LEFT);
    }

    function experienceMenu() as Void {
        var items = [
            { :label => "Beginner", :id => :exp_beginner },
            { :label => "Intermediate", :id => :exp_intermediate },
            { :label => "Advanced", :id => :exp_advanced }
        ];

        var menu = new CustomMenuView("Set Experience", items, method(:onSubMenuItem), method(:onSubMenuBack), "UP/DOWN select, START confirm");
        WatchUi.pushView(menu, new CustomMenuDelegate(menu), WatchUi.SLIDE_LEFT);
    }

    function genderMenu() as Void {
        var items = [
            { :label => "Male", :id => :user_male },
            { :label => "Female", :id => :user_female },
            { :label => "Other", :id => :user_other }
        ];

        var menu = new CustomMenuView("Set Gender", items, method(:onSubMenuItem), method(:onSubMenuBack), "UP/DOWN select, START confirm");
        WatchUi.pushView(menu, new CustomMenuDelegate(menu), WatchUi.SLIDE_LEFT);
    }

    // Callback for the experience/gender submenus
    function onSubMenuItem(id as Symbol) as Void {
        var app = Application.getApp() as GarminApp;

        if (id == :exp_beginner) { app._experienceLvl = 1.06; System.println("Experience updated to: " + app._experienceLvl); }
        else if (id == :exp_intermediate) { app._experienceLvl = 1.04; System.println("Experience updated to: " + app._experienceLvl); }
        else if (id == :exp_advanced) { app._experienceLvl = 1.02; System.println("Experience updated to: " + app._experienceLvl); }
        else if (id == :user_male) { app._userGender = 0; System.println("Gender updated to: " + app._userGender); }
        else if (id == :user_female) { app._userGender = 1; System.println("Gender updated to: " + app._userGender); }
        else { app._userGender = 2; System.println("Gender updated to: " + app._userGender); }

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    // Callback for submenu BACK
    function onSubMenuBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

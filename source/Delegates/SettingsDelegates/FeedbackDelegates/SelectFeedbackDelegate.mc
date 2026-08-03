import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SelectFeedbackDelegate extends WatchUi.BehaviorDelegate { 

    var app = Application.getApp() as GarminApp;
    var gender = "Other";// make sure to change to above!!

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle a feedback item id selected from the custom menu
    function onMenuSelect(id as Symbol) as Void {
        if (id == :haptic_feedback){
            System.println("Haptic menu selected");
            pushHapticSettings();
        } 
        else if (id == :audible_feedback){
            System.println("Audible menu selected");
            pushAudibleSettings();
        } else {System.println("ERROR");}
    }

    function pushHapticSettings() as Void{
        var items = [
            { :label => "Low",    :id => :haptic_low },
            { :label => "Medium", :id => :haptic_med },
            { :label => "High",   :id => :haptic_high }
        ];

        var menu = new CustomMenuView("Haptic Settings", items, method(:onHapticItem), method(:onFeedbackBack), "UP/DOWN select, START confirm");
        WatchUi.pushView(menu, new CustomMenuDelegate(menu), WatchUi.SLIDE_LEFT);
    }

    function pushAudibleSettings() as Void{
        var items = [
            { :label => "Low",    :id => :audible_low },
            { :label => "Medium", :id => :audible_med },
            { :label => "High",   :id => :audible_high }
        ];

        var menu = new CustomMenuView("Audible Settings", items, method(:onAudibleItem), method(:onFeedbackBack), "UP/DOWN select, START confirm");
        WatchUi.pushView(menu, new CustomMenuDelegate(menu), WatchUi.SLIDE_LEFT);
    }

    // Callback for haptic submenu item selection
    function onHapticItem(id as Symbol) as Void {
        var haptic = new SelectHapticDelegate();
        haptic.onMenuSelect(id);
    }

    // Callback for audible submenu item selection
    function onAudibleItem(id as Symbol) as Void {
        var audible = new SelectAudibleDelegate();
        audible.onMenuSelect(id);
    }

    // Callback for feedback submenu BACK
    function onFeedbackBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    // Returns back one menu
    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
        return true;
    }
}

import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Attention;

class SelectHapticDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;

    var lowProfile = [new Attention.VibeProfile(25,250)];
    var medProfile = [new Attention.VibeProfile(50,250)];
    var highProfile = [new Attention.VibeProfile(50,500)];
    var app = Application.getApp() as GarminApp;
    var haptic = app.getHaptic();

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;

        var newTitle = Lang.format("Haptic: $1$", [haptic]);
        
        // This updates the UI when the cadence is changed
        _menu.setTitle(newTitle);
    }

    function onSelect(item) as Void {

        var id = item.getId();
        
        //Try to change cadence range based off menu selection
        if (id == :haptic_low){
            System.println("Haptic Feedback: LOW");
            Attention.vibrate(lowProfile);
            app.setHaptic("low");
        } 
        else if (id == :haptic_med){
            System.println("Haptic Feedback: MEDIUM");
            Attention.vibrate(medProfile);
            app.setHaptic("med");
        } 
        else if (id == :haptic_high){
            System.println("Haptic Feedback: HIGH");
            Attention.vibrate(highProfile);
            app.setHaptic("high");
        } else {System.println("ERROR");}

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onMenuItem(item as Symbol) as Void {}

    // Returns back one menu
    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT); 
    }
}
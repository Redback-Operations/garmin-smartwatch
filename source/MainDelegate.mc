import Toybox.Lang;
import Toybox.WatchUi;

class MainDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        var settingsView = new SettingsView();
        
        //Switches the screen to settings view by holding up button
        WatchUi.pushView(settingsView, new SettingsDelegate(settingsView), WatchUi.SLIDE_UP);

        return true;
    }

    function onNextPage() as Boolean {
        var advancedView = new AdvancedView();

        // Switches the screen to advanced view by holding down button
        WatchUi.pushView(advancedView, new AdvancedViewDelegate(advancedView), WatchUi.SLIDE_DOWN);

        return true;
    }

}
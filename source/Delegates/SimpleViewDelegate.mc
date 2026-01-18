import Toybox.Lang;
import Toybox.WatchUi;

class SimpleViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        var settingsMenu = new WatchUi.Menu2({ :title => "Settings" });

        settingsMenu.addItem(new WatchUi.MenuItem("Profile", null, :set_profile, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Customization", null, :cust_options, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Feedback", null, :feedback_options, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Cadence Range", null, :cadence_range, null));

        WatchUi.pushView(settingsMenu, new SettingsMenuDelegate(), WatchUi.SLIDE_UP);
        
        return true;
    }

    function onNextPage() as Boolean {
        var advancedView = new AdvancedView();

        // Switches the screen to advanced view by holding down button
        WatchUi.pushView(advancedView, new AdvancedViewDelegate(advancedView), WatchUi.SLIDE_DOWN);

        return true;
    }

    function onBack() as Boolean {
        return true;
    }

}
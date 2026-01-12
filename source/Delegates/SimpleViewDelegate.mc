import Toybox.Lang;
import Toybox.WatchUi;

class SimpleViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

function onMenu() as Boolean {

    var menu = new WatchUi.Menu2({ :title => "Settings" });

    menu.addItem(new WatchUi.MenuItem("Cadence Threshold", null, :settings_cadence, null));
    menu.addItem(new WatchUi.MenuItem("Alerts", null, :settings_alerts, null));
    menu.addItem(new WatchUi.MenuItem("Brightness", null, :settings_brightness, null));
    menu.addItem(new WatchUi.MenuItem("Font Size", null, :settings_font_size, null));
    menu.addItem(new WatchUi.MenuItem("Reset Statistics", null, :settings_reset_stats, null));
    //Switches the screen to settings view by holding up button
    WatchUi.pushView(menu, new SettingsMenuDelegate(menu), WatchUi.SLIDE_UP);
    return true;
}

    function onNextPage() as Boolean {
        var advancedView = new AdvancedView();

        //Switches the screen to advanced view by holding down button
        WatchUi.pushView(advancedView, new AdvancedViewDelegate(advancedView), WatchUi.SLIDE_DOWN);

        return true;
    }

    function onBack() as Boolean {
        return true;
    }

}
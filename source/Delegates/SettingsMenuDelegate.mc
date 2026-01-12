import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) as Void {
        var id = item.getId();

        if (id == :settings_cadence) {
            var app = Application.getApp() as GarminApp;
            var minCadence = app.getMinCadence();
            var maxCadence = app.getMaxCadence();

            var cadenceMenu = new WatchUi.Menu2({
                :title => Lang.format("Cadence: $1$ - $2$", [minCadence, maxCadence])
            });

            cadenceMenu.addItem(new WatchUi.MenuItem("Min +5", null, :item_inc_min, null));
            cadenceMenu.addItem(new WatchUi.MenuItem("Min -5", null, :item_dec_min, null));
            cadenceMenu.addItem(new WatchUi.MenuItem("Max +5", null, :item_inc_max, null));
            cadenceMenu.addItem(new WatchUi.MenuItem("Max -5", null, :item_dec_max, null));

            WatchUi.pushView(cadenceMenu, new SelectCadenceDelegate(cadenceMenu), WatchUi.SLIDE_LEFT);
            return;
        }

        if (id == :settings_reset_stats) {
            var app = Application.getApp() as GarminApp;
             app.resetStatistics();

            WatchUi.requestUpdate();

            //Show confirmation screen
            var done = new WatchUi.Menu2({ :title => "Reset" });
            done.addItem(new WatchUi.MenuItem("Statistics cleared", null, :ok, null));
            WatchUi.pushView(done, new StaticMenuDelegate(done), WatchUi.SLIDE_LEFT);

            return;
        }

        //Alerts/Brightness/Font Size: placeholder for now
        var todo = new WatchUi.Menu2({ :title => "Coming soon" });
        todo.addItem(new WatchUi.MenuItem("Not implemented yet", null, :todo, null));
        WatchUi.pushView(todo, new StaticMenuDelegate(todo), WatchUi.SLIDE_LEFT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
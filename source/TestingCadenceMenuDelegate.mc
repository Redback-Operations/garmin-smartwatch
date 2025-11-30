import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class TestingCadenceMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        var app = getApp();
        if (item == :item_inc_min) {
            var v = app.getMinCadence() + 5;
            if (v >= app.getMaxCadence()) {
                v = app.getMaxCadence() - 1;
            }
            app.setMinCadence(v);
            System.println("Min cadence set to " + v.toString());
        } else if (item == :item_dec_min) {
            var v = app.getMinCadence() - 5;
            if (v < 0) {
                v = 0;
            }
            app.setMinCadence(v);
            System.println("Min cadence set to " + v.toString());
        } else if (item == :item_inc_max) {
            var v = app.getMaxCadence() + 5;
            app.setMaxCadence(v);
            System.println("Max cadence set to " + v.toString());
        } else if (item == :item_dec_max) {
            var v = app.getMaxCadence() - 5;
            if (v <= app.getMinCadence()) {
                v = app.getMinCadence() + 1;
            }
            app.setMaxCadence(v);
            System.println("Max cadence set to " + v.toString());
        } else if (item == :item_reset_zones) {
            app.setMinCadence(90);
            app.setMaxCadence(100);
            System.println("Cadence zones reset to 100-150");
        }
        // Request view to update so zone display refreshes
        WatchUi.requestUpdate();
    }

}
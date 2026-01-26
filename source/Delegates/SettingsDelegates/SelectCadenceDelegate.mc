import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;

class SelectCadenceDelegate extends WatchUi.Menu2InputDelegate { 

    private var _menu as WatchUi.Menu2;
    var app = Application.getApp() as GarminApp;

    function initialize(menu as WatchUi.Menu2) {
        Menu2InputDelegate.initialize();
        _menu = menu;
    }

    function onSelect(item) as Void {
        var id = item.getId();
        
        System.println("[DEBUG] SelectCadenceDelegate onSelect called with id: " + id);

        // Show picker for min or max cadence
        if (id == :item_set_min) {
            System.println("[DEBUG] Opening minCadencePicker");
            minCadencePicker();
        } 
        else if (id == :item_set_max) {
            System.println("[DEBUG] Opening maxCadencePicker");
            maxCadencePicker();
        }
        else {
            System.println("[DEBUG] Unknown menu item id: " + id);
        }
    }

    function onMenuItem(item as Symbol) as Void {
        System.println("[DEBUG] onMenuItem called with: " + item);
        // Legacy code - no longer used with pickers
        // Keeping for backwards compatibility if needed
    }

    // Returns back one menu
    function onBack() as Void {
        System.println("[DEBUG] SelectCadenceDelegate onBack called");
        WatchUi.popView(WatchUi.SLIDE_BLINK); 
    }

    function minCadencePicker() as Void {
        System.println("[DEBUG] minCadencePicker() started");
        
        var currentMin = app.getMinCadence();
        if (currentMin == null) { currentMin = 120; } // Default 120 spm
        
        System.println("[DEBUG] Current min cadence: " + currentMin);

        try {
            // Range: 50-200, increment by 1, label " spm"
            var factory = new ProfilePickerFactory(50, 200, 1, {:label=>" spm"});
            System.println("[DEBUG] ProfilePickerFactory created");

            var picker = new WatchUi.Picker({
                :title => new WatchUi.Text({
                    :text=>"Min Cadence", 
                    :locX=>WatchUi.LAYOUT_HALIGN_CENTER, 
                    :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, 
                    :color=>Graphics.COLOR_WHITE
                }),
                :pattern => [factory],
                :defaults => [factory.getIndex(currentMin)]
            });
            System.println("[DEBUG] Picker created");

            WatchUi.pushView(picker, new CadenceRangePickerDelegate(:cadence_min, _menu), WatchUi.SLIDE_LEFT);
            System.println("[DEBUG] Picker pushed to view");
        }
        catch (ex) {
            System.println("[ERROR] Exception in minCadencePicker: " + ex.getErrorMessage());
        }
    }

    function maxCadencePicker() as Void {
        System.println("[DEBUG] maxCadencePicker() started");
        
        var currentMax = app.getMaxCadence();
        if (currentMax == null) { currentMax = 150; } // Default 150 spm
        
        System.println("[DEBUG] Current max cadence: " + currentMax);

        try {
            // Range: 50-200, increment by 1, label " spm"
            var factory = new ProfilePickerFactory(50, 200, 1, {:label=>" spm"});
            System.println("[DEBUG] ProfilePickerFactory created");

            var picker = new WatchUi.Picker({
                :title => new WatchUi.Text({
                    :text=>"Max Cadence", 
                    :locX=>WatchUi.LAYOUT_HALIGN_CENTER, 
                    :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, 
                    :color=>Graphics.COLOR_WHITE
                }),
                :pattern => [factory],
                :defaults => [factory.getIndex(currentMax)]
            });
            System.println("[DEBUG] Picker created");
            
            WatchUi.pushView(picker, new CadenceRangePickerDelegate(:cadence_max, _menu), WatchUi.SLIDE_LEFT);
            System.println("[DEBUG] Picker pushed to view");
        }
        catch (ex) {
            System.println("[ERROR] Exception in maxCadencePicker: " + ex.getErrorMessage());
        }
    }
}

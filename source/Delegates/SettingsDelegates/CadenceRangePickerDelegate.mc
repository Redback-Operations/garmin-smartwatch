import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Lang;

class CadenceRangePickerDelegate extends WatchUi.PickerDelegate {

    private var _typeId;
    private var _menu;

    function initialize(typeId, menu) {
        PickerDelegate.initialize();
        _typeId = typeId;
        _menu = menu;
        System.println("[DEBUG] CadenceRangePickerDelegate initialized with typeId: " + typeId);
    }

    function onAccept(values as Array) as Boolean {
        System.println("[DEBUG] CadenceRangePickerDelegate onAccept called");
        
        var pickedValue = values[0]; // Gets the "selected" value
        System.println("[DEBUG] Picked value: " + pickedValue);
        
        var app = Application.getApp() as GarminApp;

        if (_typeId == :cadence_min) {
            System.println("[INFO] Min Cadence Saved: " + pickedValue);
            app.setMinCadence(pickedValue);
        }
        else if (_typeId == :cadence_max) {
            System.println("[INFO] Max Cadence Saved: " + pickedValue);
            app.setMaxCadence(pickedValue);
        }

        // Update the menu title to show new range
        if (_menu != null) {
            var newMin = app.getMinCadence();
            var newMax = app.getMaxCadence();
            var newTitle = Lang.format("Cadence: $1$ - $2$", [newMin, newMax]);
            _menu.setTitle(newTitle);
            System.println("[DEBUG] Menu title updated to: " + newTitle);
        }

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onCancel() as Boolean {
        System.println("[DEBUG] CadenceRangePickerDelegate onCancel called");
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

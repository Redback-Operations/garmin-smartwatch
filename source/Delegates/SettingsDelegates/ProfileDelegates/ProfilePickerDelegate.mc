import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application;
import Toybox.Lang;

class ProfilePickerDelegate extends WatchUi.PickerDelegate {

    private var _typeId;

    function initialize(typeId) {
        PickerDelegate.initialize();
        _typeId = typeId;
    }

    function onAccept(values as Array) as Boolean {
        var pickedValue = values[0]; // Gets the "selected" value
        
        //var app = Application.getApp();

        if (_typeId == :prof_height) {
            System.println("Height Saved: " + pickedValue);
            //app.setUserHeight(pickedValue);
        }
        else if (_typeId == :prof_speed) {
             System.println("Speed Saved: " + pickedValue);
             //app.setUserSpeed(pickedValue);
        }

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
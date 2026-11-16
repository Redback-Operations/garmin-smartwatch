import Toybox.WatchUi;
import Toybox.Application;

class ProfilePickerDelegate extends WatchUi.PickerDelegate {
    private var _type;

    function initialize(type) {
        PickerDelegate.initialize();
        _type = type;
    }

    function onAccept(values) {
        var app = Application.getApp() as GarminApp;
        var selectedValue = values[0];

        if (_type == :prof_height) {
            app.setUserHeight(selectedValue.toNumber());
        } 
        else if (_type == :prof_speed || _type == :profile_speed) { 
            app.setUserSpeed(selectedValue.toFloat());
            System.println("Speed saved to App: " + selectedValue);
        }

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true; // This lets the watch know the "Back" event is handled
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

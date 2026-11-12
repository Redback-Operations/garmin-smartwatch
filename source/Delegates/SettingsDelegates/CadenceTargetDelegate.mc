import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

class CadenceTargetDelegate extends WatchUi.BehaviorDelegate {

    private var _target as Number;

    function initialize() {
        BehaviorDelegate.initialize();

        var app = Application.getApp() as GarminApp;

        _target = app.getTargetCadence();
    }

    function onBack() as Boolean {

        WatchUi.popView(WatchUi.SLIDE_DOWN);

        return true;
    }

    function onSelect() as Boolean {

        var app = Application.getApp() as GarminApp;

        app.setTargetCadence(_target);

        WatchUi.popView(WatchUi.SLIDE_UP);

        return true;
    }

    // FR165 (and other 5-button watches) map UP/DOWN to page behaviors
    // instead of delivering KEY_UP/KEY_DOWN to onKey().
    function onPreviousPage() as Boolean {
        adjustTarget(1);
        return true;
    }

    function onNextPage() as Boolean {
        adjustTarget(-1);
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {

        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_UP) {
            adjustTarget(1);
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            adjustTarget(-1);
            return true;
        }

        return false;
    }

    private function adjustTarget(delta as Number) as Void {
        var app = Application.getApp() as GarminApp;

        _target = _target + delta;

        if (_target < 1) {
            _target = 1;
        }

        app.setTargetCadence(_target);

        WatchUi.requestUpdate();
    }
}

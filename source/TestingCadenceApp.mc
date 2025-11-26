import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TestingCadenceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }
        private var _minCadence = 100;
        private var _maxCadence = 150;

        function getMinCadence() as Number {
            return _minCadence;
        }

        function getMaxCadence() as Number {
            return _maxCadence;
        }

        function setMinCadence(val as Number) as Void {
            _minCadence = val;
        }

        function setMaxCadence(val as Number) as Void {
            _maxCadence = val;
        }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new TestingCadenceView(), new TestingCadenceDelegate() ];
    }

}

function getApp() as TestingCadenceApp {
    return Application.getApp() as TestingCadenceApp;
}

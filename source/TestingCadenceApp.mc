import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Timer;

class TestingCadenceApp extends Application.AppBase {

    private var _minCadence = 100;
    private var _maxCadence = 150;
    private var _zoneHistory = new [60]; // Store 60 data points (3 minutes at 3-second intervals)
    private var _historyIndex = 0;
    private var _historyTimer;

    function initialize() {
        AppBase.initialize();
        
        // Initialize history array with null values
        for (var i = 0; i < 60; i++) {
            _zoneHistory[i] = null;
        }
        
        // Start timer to update zone history every 3 seconds
        _historyTimer = new Timer.Timer();
        _historyTimer.start(method(:updateZoneHistory), 3000, true);
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if (_historyTimer != null) {
            _historyTimer.stop();
        }
    }

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

    // Zone history management
    function updateZoneHistory() as Void {
        var info = Activity.getActivityInfo();
        
        var zoneState = null;
        if (info != null && info.currentCadence != null) {
            var c = info.currentCadence;
            if (c < _minCadence) {
                zoneState = -1; // Below zone (blue)
            } else if (c > _maxCadence) {
                zoneState = 1;  // Above zone (red)
            } else {
                zoneState = 0;  // In zone (green)
            }
        }
        
        // Add to circular buffer
        _zoneHistory[_historyIndex] = zoneState;
        _historyIndex = (_historyIndex + 1) % 60;
    }

    function getZoneHistory() as Array {
        return _zoneHistory;
    }

    function getHistoryIndex() as Number {
        return _historyIndex;
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new TestingCadenceView(), new TestingCadenceDelegate() ];
    }

}

function getApp() as TestingCadenceApp {
    return Application.getApp() as TestingCadenceApp;
}

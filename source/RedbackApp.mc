import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Activity;

class RedbackApp extends Application.AppBase {

    const MAX_BARS = 60;
    const BASELINE_AVG_CADENCE = 150;
    const HEIGHT_BASELINE = 170;
    const STEP_RATE = 6;
    
    // Vars for graph display
    private var _zoneHistory as Array<Float?> = new [MAX_BARS]; // Store 60 data points (1 minutes at 1-second intervals)
    private var _historyIndex = 0;
    private var _historyCount = 0;
    private var _historyTimer;

    // Cadence vars
    private var _minCadence = 100;
    private var _maxCadence = 150;

    // Temp user data
    private var _userHeight = 160;
    private var _userSpeed = 0;
    private var _trainingLvl = :Beginner;


    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

            // Zone history management
    function updateZoneHistory() as Void {
        var info = Activity.getActivityInfo();
        
        //var zoneState = null;
        if (info != null && info.currentCadence != null) {
            var newCadence = info.currentCadence.toFloat();
            _zoneHistory[_historyIndex] = newCadence;
            // Add to circular buffer
            _historyIndex = (_historyIndex + 1) % MAX_BARS;
            if (_historyCount < MAX_BARS) { _historyCount++; }
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

    function getZoneHistory() as Array<Float?> {
        return _zoneHistory;
    }

    function getHistoryCount() as Number {
        return _historyCount;
    }

    function getHistoryIndex() as Number {
        return _historyIndex;
    }


    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new MainView(), new MainDelegate() ];
    }

}

function getApp() as RedbackApp {
    return Application.getApp() as RedbackApp;
}

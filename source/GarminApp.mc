import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GarminApp extends Application.AppBase {
    const MAX_BARS = 60;
    const BASELINE_AVG_CADENCE = 150;
    const HEIGHT_BASELINE = 170;
    const STEP_RATE = 6;
    //for persistent settings
    const PROP_MIN_CADENCE = "minCadence";
    const PROP_MAX_CADENCE = "maxCadence";

    private var _idealMinCadence = 90;
    private var _idealMaxCadence = 100;
    private var _zoneHistory as Array<Float?> = new [MAX_BARS]; // Store 60 data points (1 minutes at 1-second intervals)
    
    private var _historyIndex = 0;
    private var _historyCount = 0;
    private var _historyTimer;

    enum {
        Beginner = 0.96,
        Intermediate = 1,
        Advanced = 1.04
    }

    //user info (testing with dummy value rn, implement user profile input later)
    private var _userHeight = 160;
    private var _userSpeed = 0;
    private var _trainingLvl = Beginner;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        loadSettings();
        _historyTimer = new Timer.Timer();
        _historyTimer.start(method(:updateZoneHistory), 1000, true);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if (_historyTimer != null) {
            _historyTimer.stop();
        }
    }

    //Persistent Settings
    function loadSettings() as Void {
        var min = Application.Storage.getValue(PROP_MIN_CADENCE);
        var max = Application.Storage.getValue(PROP_MAX_CADENCE);

        if (min != null) { _idealMinCadence = min as Number; }
        if (max != null) { _idealMaxCadence = max as Number; }
        if (_idealMinCadence >= _idealMaxCadence) {
            _idealMinCadence = 90;
            _idealMaxCadence = 100;
        }
    }

    function saveSettings() as Void {
        Application.Storage.setValue(PROP_MIN_CADENCE, _idealMinCadence);
        Application.Storage.setValue(PROP_MAX_CADENCE, _idealMaxCadence);
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

    //Reset Statistics 
    function resetStatistics() as Void {
        _zoneHistory = new [MAX_BARS];
        _historyIndex = 0;
        _historyCount = 0;
    }

    function getMinCadence() as Number {
        return _idealMinCadence;
    }
    
    function getMaxCadence() as Number {
        return _idealMaxCadence;
    }

    function setMinCadence(value as Number) as Void {
        _idealMinCadence = value;
        saveSettings();
    }

    function setMaxCadence(value as Number) as Void {
        _idealMaxCadence = value;
        saveSettings();
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
        return [ new SimpleView(), new SimpleViewDelegate() ];
    }

}

function getApp() as GarminApp {
    return Application.getApp() as GarminApp;
}
import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GarminApp extends Application.AppBase {
    const MAX_BARS = 60;

    private var _idealMinCadence = 80;
    private var _idealMaxCadence = 100;
    private var _cadenceIndex = 0;
    private var _cadenceCount = 0;
    private var _cadenceHistory as Array<Float?> = new [MAX_BARS]; // Store 60 data points (1 minutes at 1-second intervals)

    var globalTimer;

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
        globalTimer = new Timer.Timer();
        globalTimer.start(method(:updateCadence),1000,true);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if(globalTimer != null){
            globalTimer.stop();
            globalTimer = null;
        }
    }


    function updateCadence() as Void {
        var info = Activity.getActivityInfo();
        
        //var zoneState = null;
        if (info != null && info.currentCadence != null) {
            var newCadence = info.currentCadence;
            _cadenceHistory[_cadenceIndex] = newCadence.toFloat();
            // Add to circular buffer
            _cadenceIndex = (_cadenceIndex + 1) % MAX_BARS;
            if (_cadenceCount < MAX_BARS) { _cadenceCount++; }
        }

        //WatchUi.requestUpdate();

    }

    function getMinCadence() as Number {
        return _idealMinCadence;
    }
    
    function getMaxCadence() as Number {
        return _idealMaxCadence;    
    }

    function getCadenceHistory() as Array<Float?> {
        return _cadenceHistory;
    }

    function getCadenceIndex() as Number {
        return _cadenceIndex;
    }

    function getCadenceCount() as Number {
        return _cadenceCount;
    }

    function setMinCadence(value as Number) as Void {
        _idealMinCadence = value;
    }

    function setMaxCadence(value as Number) as Void {
        _idealMaxCadence = value;
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SimpleView(), new SimpleViewDelegate() ];
    }

    
}
function getApp() as GarminApp {
    return Application.getApp() as GarminApp;
}

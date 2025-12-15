import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Activity;
import Toybox.System;

class GarminApp extends Application.AppBase {
    const MAX_BARS = 60;

    private var _idealMinCadence = 80;
    private var _idealMaxCadence = 100;
    private var _cadenceIndex = 0;
    private var _cadenceCount = 0;
    private var _cadenceHistory as Array<Float?> = new [MAX_BARS];

    var globalTimer;

    enum {
        Beginner = 0.96,
        Intermediate = 1,
        Advanced = 1.04
    }

    private var _userHeight = 160;
    private var _userSpeed = 0;
    private var _trainingLvl = Beginner;

    function initialize() {
        AppBase.initialize();
        System.println("[INFO] App initialized");
    }

    function onStart(state as Dictionary?) as Void {
        System.println("[INFO] App starting");
        
        // Log memory on startup
        Logger.logMemoryStats("Startup");
        
        globalTimer = new Timer.Timer();
        globalTimer.start(method(:updateCadence), 1000, true);
    }

    function onStop(state as Dictionary?) as Void {
        System.println("[INFO] App stopping");
        
        if(globalTimer != null){
            globalTimer.stop();
            globalTimer = null;
        }
        
        // Log memory on shutdown
        Logger.logMemoryStats("Shutdown");
    }

    function updateCadence() as Void {
        var info = Activity.getActivityInfo();
        
        if (info != null && info.currentCadence != null) {
            var newCadence = info.currentCadence;
            _cadenceHistory[_cadenceIndex] = newCadence.toFloat();
            _cadenceIndex = (_cadenceIndex + 1) % MAX_BARS;
            if (_cadenceCount < MAX_BARS) { _cadenceCount++; }
        }
        
        // Log memory every 60 seconds
        if (_cadenceIndex % 60 == 0 && _cadenceIndex > 0) {
            Logger.logMemoryStats("Runtime");
        }
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

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SimpleView(), new SimpleViewDelegate() ];
    }
}

function getApp() as GarminApp {
    return Application.getApp() as GarminApp;
}

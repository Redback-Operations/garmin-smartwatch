import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Activity;
import Toybox.System;
import Toybox.ActivityRecording;

class GarminApp extends Application.AppBase {
    const MAX_BARS = 60;

    private var _idealMinCadence = 80;
    private var _idealMaxCadence = 100;
    private var _cadenceIndex = 0;
    private var _cadenceCount = 0;
    private var _cadenceHistory as Array<Float?> = new [MAX_BARS];

    var globalTimer;
    var session as ActivityRecording.Session?;
    var isRecording as Boolean = false;

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
        
        // Stop recording if active
        if (isRecording && session != null) {
            stopRecording();
        }
        
        if(globalTimer != null){
            globalTimer.stop();
            globalTimer = null;
        }
        
        // Log memory on shutdown
        Logger.logMemoryStats("Shutdown");
    }

    function startRecording() as Void {
        if (!isRecording) {
            System.println("[INFO] Starting activity recording");
            
            // Create a new session
            session = ActivityRecording.createSession({
                :name => "Cadence Training",
                :sport => ActivityRecording.SPORT_RUNNING,
                :subSport => ActivityRecording.SUB_SPORT_GENERIC
            });
            
            if (session != null) {
                session.start();
                isRecording = true;
                System.println("[INFO] Recording started successfully");
            } else {
                System.println("[ERROR] Failed to create session");
            }
        }
    }

    function stopRecording() as Void {
        if (isRecording && session != null) {
            System.println("[INFO] Stopping activity recording");
            session.stop();
            isRecording = false;
            System.println("[INFO] Recording stopped");
        }
    }

    function saveRecording() as Void {
        if (session != null) {
            System.println("[INFO] Saving activity");
            session.save();
            session = null;
            isRecording = false;
            System.println("[INFO] Activity saved");
        }
    }

    function discardRecording() as Void {
        if (session != null) {
            System.println("[INFO] Discarding activity");
            session.discard();
            session = null;
            isRecording = false;
            System.println("[INFO] Activity discarded");
        }
    }

    function isActivityRecording() as Boolean {
        return isRecording;
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

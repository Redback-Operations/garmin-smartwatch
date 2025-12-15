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
    private var _cadenceHistory as Array<Float?> = new [MAX_BARS]; // Store 60 data points (1 minute at 1-second intervals)

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
        
        // Initialize the logging system
        try {
            Logger.initialize();
            Logger.log(Logger.INFO, "GarminApp", "Application initialized");
            Logger.log(Logger.INFO, "GarminApp", "Training level: " + _trainingLvl);
            Logger.log(Logger.INFO, "GarminApp", "Cadence range: " + _idealMinCadence + "-" + _idealMaxCadence);
        } catch (e) {
            // Fallback to System.println if logger fails
            System.println("Failed to initialize logger: " + e.getErrorMessage());
        }
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        try {
            Logger.log(Logger.INFO, "GarminApp", "Application starting");
            Logger.logMemoryStats("GarminApp");
            
            // Initialize and start the global timer
            globalTimer = new Timer.Timer();
            globalTimer.start(method(:updateCadence), 1000, true);
            
            Logger.log(Logger.INFO, "GarminApp", "Global cadence timer started (1s interval)");
            
        } catch (e) {
            Logger.logCrash("GarminApp", "Failed to start application", e);
            // Re-throw critical errors
            throw e;
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        try {
            Logger.log(Logger.INFO, "GarminApp", "Application stopping");
            Logger.log(Logger.INFO, "GarminApp", "Total cadence readings: " + _cadenceCount);
            
            // Stop and cleanup the global timer
            if(globalTimer != null){
                globalTimer.stop();
                globalTimer = null;
                Logger.log(Logger.INFO, "GarminApp", "Global timer stopped");
            }
            
            // Log final memory state
            Logger.logMemoryStats("GarminApp");
            
            // Ensure all logs are flushed to storage
            Logger.shutdown();
            
        } catch (e) {
            // Even if logging fails, try to output to console
            System.println("Error during app stop: " + e.getErrorMessage());
        }
    }

    /**
     * Update cadence data from activity information
     * Called every second by the global timer
     */
    function updateCadence() as Void {
        try {
            var info = Activity.getActivityInfo();
            
            if (info != null && info.currentCadence != null) {
                var newCadence = info.currentCadence;
                
                // Store in circular buffer
                _cadenceHistory[_cadenceIndex] = newCadence.toFloat();
                _cadenceIndex = (_cadenceIndex + 1) % MAX_BARS;
                
                if (_cadenceCount < MAX_BARS) { 
                    _cadenceCount++; 
                }
                
                // Log cadence periodically (every 10 seconds) to avoid log spam
                if (_cadenceIndex % 10 == 0) {
                    Logger.log(Logger.DEBUG, "GarminApp", "Cadence update: " + newCadence + " spm (count: " + _cadenceCount + ")");
                }
                
                // Log if cadence is outside ideal range
                if (newCadence < _idealMinCadence || newCadence > _idealMaxCadence) {
                    if (_cadenceIndex % 5 == 0) { // Log every 5 seconds when out of range
                        var status = newCadence < _idealMinCadence ? "below" : "above";
                        Logger.log(Logger.WARNING, "GarminApp", "Cadence " + status + " target range: " + newCadence + " spm");
                    }
                }
                
            } else {
                // Log when activity info is unavailable (but not too frequently)
                if (_cadenceIndex % 30 == 0) { // Log every 30 seconds
                    if (info == null) {
                        Logger.log(Logger.WARNING, "GarminApp", "Activity info unavailable");
                    } else {
                        Logger.log(Logger.WARNING, "GarminApp", "Current cadence is null");
                    }
                }
            }
            
            // Periodically log memory stats (every minute)
            if (_cadenceIndex % 60 == 0 && _cadenceIndex > 0) {
                Logger.logMemoryStats("GarminApp");
            }
            
        } catch (e) {
            Logger.logError("GarminApp", "Error updating cadence", e);
            // Don't re-throw - we want the timer to continue
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
        try {
            var oldValue = _idealMinCadence;
            _idealMinCadence = value;
            Logger.log(Logger.INFO, "GarminApp", "Min cadence updated: " + oldValue + " -> " + value);
        } catch (e) {
            Logger.logError("GarminApp", "Error setting min cadence", e);
            // Still try to set the value
            _idealMinCadence = value;
        }
    }

    function setMaxCadence(value as Number) as Void {
        try {
            var oldValue = _idealMaxCadence;
            _idealMaxCadence = value;
            Logger.log(Logger.INFO, "GarminApp", "Max cadence updated: " + oldValue + " -> " + value);
        } catch (e) {
            Logger.logError("GarminApp", "Error setting max cadence", e);
            // Still try to set the value
            _idealMaxCadence = value;
        }
    }

    // Additional getters for user info (if needed for future features)
    function getUserHeight() as Number {
        return _userHeight;
    }
    
    function getUserSpeed() as Number {
        return _userSpeed;
    }
    
    function getTrainingLevel() as Number {
        return _trainingLvl;
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        try {
            Logger.log(Logger.INFO, "GarminApp", "Loading initial view (SimpleView)");
            return [ new SimpleView(), new SimpleViewDelegate() ];
        } catch (e) {
            Logger.logCrash("GarminApp", "Critical: Failed to load initial view", e);
            // Re-throw since we can't function without a view
            throw e;
        }
    }
}

/**
 * Global helper function to get the app instance
 * This is used throughout the app to access shared state
 */
function getApp() as GarminApp {
    return Application.getApp() as GarminApp;
}

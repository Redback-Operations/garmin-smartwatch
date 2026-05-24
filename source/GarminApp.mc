import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.System;
import Toybox.Application.Storage;

class GarminApp extends Application.AppBase {
    const MAX_BARS = 280;
    const BASELINE_AVG_CADENCE = 160;
    const MAX_CADENCE = 190;
    const MIN_CQ_SAMPLES = 30;
    const DEBUG_MODE = true;

    // Property keys for persistent storage
    const PROP_USER_HEIGHT = "userHeight";
    const PROP_USER_SPEED = "userSpeed";
    const PROP_USER_GENDER = "userGender";
    const PROP_EXPERIENCE_LVL = "experienceLvl";
    const PROP_CHART_DURATION = "chartDuration";
    const PROP_MIN_CADENCE = "minCadence";
    const PROP_MAX_CADENCE = "maxCadence";
    const PROP_VIBRATION_ENABLED = "vibrationEnabled";
    const PROP_SUMMARY_ENABLED = "summaryEnabled";

    var globalTimer;
    var activitySession; // Garmin activity recording session
    
    enum SessionState {
        IDLE,
        RECORDING,
        PAUSED,
        STOPPED
    }
    
    private var _sessionState as SessionState = IDLE;
    
   enum {
    FifteenminChart = 5,    // was 3
    ThirtyminChart = 10,    // was 6 
    OneHourChart = 20,      // was 13
    TwoHourChart = 40       // was 26
}

    const CHART_ENUM_NAMES = {
        FifteenminChart => "15 Minutes",
        ThirtyminChart => "30 Minutes",
        OneHourChart => "1 Hour",
        TwoHourChart => "2 Hours"
    };

    enum {
        Beginner = 1.06,
        Intermediate = 1.04,
        Advanced = 1.02
    }

    enum {
        Male,
        Female,
        Other
    }

    var _userHeight = 170;
    var _userSpeed = 10.0;
    var _experienceLvl = 1.00;
    var _userGender = 0;
    var _chartDuration = ThirtyminChart as Number;
    private var _vibrationEnabled = true;
    private var _summaryEnabled = true;

    var _targetCadence = 160;

    private var _cadenceHistory as Array<Float?> = new [MAX_BARS];
    private var _cadenceIndex = 0;
    private var _cadenceCount = 0;
     
    private var _cadenceBarAvg as Array<Float?> = new [_chartDuration];
    private var _cadenceAvgIndex = 0;
    private var _cadenceAvgCount = 0;
  
    private var _finalCQ = null;
    private var _missingCadenceCount = 0;
    private var _finalCQConfidence = null;
    private var _finalCQTrend = null;
    private var _cqHistory as Array<Number> = [];
    
    //private var _sessionStartTime = null;
    private var _sessionPausedTime = 0;
    private var _lastPauseTime = null;

    // Activity metrics captured when monitoring stops
    private var _sessionDuration = null; // milliseconds
    private var _sessionDistance = null; // centimeters
    private var _avgHeartRate = null; // bpm
    private var _peakHeartRate = null; // bpm

    function initialize() {
        AppBase.initialize();
        System.println("[INFO] App initialized");
        activitySession = null;

    }

    function onStart(state as Dictionary?) as Void {
        System.println("[INFO] App starting");
        //Logger.logMemoryStats("Startup");
        
        // Load saved settings from persistent storage
        loadSettings();
        
        globalTimer = new Timer.Timer();
        globalTimer.start(method(:updateCadenceBarAvg),1000,true);
    }

    function onStop(state as Dictionary?) as Void {
        System.println("[INFO] App stopping");
        
        // Stop any active session
        if (activitySession != null && activitySession.isRecording()) {
            activitySession.stop();
            activitySession = null;
        }
        
        if(globalTimer != null){
            globalTimer.stop();
            globalTimer = null;
        }
        
        //Logger.logMemoryStats("Shutdown");
        saveSettings();
    }

    function startRecording() as Void {
        if (_sessionState == RECORDING) {
            System.println("[INFO] Already recording");
            return;
        }

        System.println("[INFO] Starting activity session");

        // Create and start Garmin activity session KEEP THIS DEPRECATED NAMING!! It makes it so when the app API level is reduced it will work.
        activitySession = ActivityRecording.createSession({
            :name => "Running",
            :sport => ActivityRecording.SPORT_RUNNING,
            :subSport => ActivityRecording.SUB_SPORT_GENERIC
        });
        
        activitySession.start();
        System.println("[INFO] Garmin activity session started");

        // Reset cadence monitoring data
        _finalCQ = null;
        _finalCQConfidence = null;
        _finalCQTrend = null;
        _cqHistory = [];
        _cadenceCount = 0;
        _cadenceIndex = 0;
        _cadenceAvgCount = 0;
        _cadenceAvgIndex = 0;
        _missingCadenceCount = 0;
        //_sessionStartTime = System.getTimer();
        _sessionPausedTime = 0;
        _lastPauseTime = null;
        
        for (var i = 0; i < MAX_BARS; i++) {
            _cadenceHistory[i] = null;
        }
        for (var i = 0; i < _chartDuration; i++) {
            _cadenceBarAvg[i] = null;
        }

        _sessionState = RECORDING;
        System.println("[INFO] Starting cadence monitoring");
    }

    function pauseRecording() as Void {
        if (_sessionState != RECORDING) {
            System.println("[INFO] Cannot pause - not recording");
            return;
        }

        System.println("[INFO] Pausing activity session");
        
        // Pause Garmin activity session
        if (activitySession != null && activitySession.isRecording()) {
            activitySession.stop();
            System.println("[INFO] Garmin activity session paused");
        }
        
        _lastPauseTime = System.getTimer();
        _sessionState = PAUSED;
    }

    function resumeRecording() as Void {
        if (_sessionState != PAUSED) {
            System.println("[INFO] Cannot resume - not paused");
            return;
        }

        System.println("[INFO] Resuming activity session");
        
        // Resume Garmin activity session
        if (activitySession != null && !activitySession.isRecording()) {
            activitySession.start();
            System.println("[INFO] Garmin activity session resumed");
        }
        
        if (_lastPauseTime != null) {
            _sessionPausedTime += System.getTimer() - _lastPauseTime;
            _lastPauseTime = null;
        }
        
        _sessionState = RECORDING;
    }

    function stopRecording() as Void {
        if (_sessionState == IDLE || _sessionState == STOPPED) {
            System.println("[INFO] No active session to stop");
            return;
        }

        System.println("[INFO] Stopping activity session");

        // Stop Garmin activity session (but don't save or discard yet)
        if (activitySession != null && activitySession.isRecording()) {
            activitySession.stop();
            System.println("[INFO] Garmin activity session stopped");
        }

        if (_sessionState == PAUSED && _lastPauseTime != null) {
            _sessionPausedTime += System.getTimer() - _lastPauseTime;
            _lastPauseTime = null;
        }

        // Capture activity metrics before stopping
        captureActivityMetrics();

        var cq = computeCadenceQualityScore();

        if (cq >= 0) {
            _finalCQ = cq;
            _finalCQConfidence = computeCQConfidence();
            _finalCQTrend = computeCQTrend();

            System.println(
                "[CADENCE QUALITY] Final CQ frozen at " +
                cq.format("%d") + "% (" +
                _finalCQTrend + ", " +
                _finalCQConfidence + " confidence)"
            );

            writeDiagnosticLog();
        }

        _sessionState = STOPPED;
    }

    function resetAllSettings() as Void {
        System.println("[RESET] Resetting all settings to default");

        _targetCadence = 160;
        _chartDuration = ThirtyminChart as Number;

        _userHeight = 170;
        _userSpeed = 10.0;
        _experienceLvl = 1.00;
        _userGender = 0;

        _vibrationEnabled = true;

        _cadenceBarAvg = new [_chartDuration];
        _cadenceAvgIndex = 0;
        _cadenceAvgCount = 0;

        _cadenceHistory = new [MAX_BARS];
        _cadenceIndex = 0;
        _cadenceCount = 0;

        saveSettings();

        System.println("[RESET] All settings reset complete");
    }

        function saveSession() as Void {

            if (_sessionState != STOPPED) {
                System.println("[INFO] Cannot save - session not stopped");
                return;
            }

            System.println("[INFO] Saving activity session");
            
            if (activitySession != null) {
                activitySession.save();
                activitySession = null;
            }

            // // STORE DATA
            // if (_sessionStartTime != null) {
            //     _sessionDuration = System.getTimer() - _sessionStartTime - _sessionPausedTime;
            // }
            if (_sessionDuration == null) {
            System.println("[WARN] No duration captured");
            }

            System.println("[SAVE] Duration stored: " + _sessionDuration);
            System.println("[SAVE] Distance stored: " + _sessionDistance);

           
           // resetSession();

            System.println("[INFO] Ready for summary view");
        }



    function discardSession() as Void {
        if (_sessionState != STOPPED) {
            System.println("[INFO] Cannot discard - session not stopped");
            return;
        }

        System.println("[INFO] Discarding activity session");
        
        // Discard Garmin activity session
        if (activitySession != null) {
            activitySession.discard();
            System.println("[INFO] Garmin activity session discarded");
            activitySession = null;
        }
        
        resetSession();
    }

    function resetSession() as Void {
        System.println("[INFO] Resetting session");
        
        _sessionState = IDLE;
        _finalCQ = null;
        _finalCQConfidence = null;
        _finalCQTrend = null;
        _cqHistory = [];
        _cadenceCount = 0;
        _cadenceIndex = 0;
        _cadenceAvgCount = 0;
        _cadenceAvgIndex = 0;
        _missingCadenceCount = 0;
        //_sessionStartTime = null;
        _sessionPausedTime = 0;
        _lastPauseTime = null;
        _sessionDuration = null;
        _sessionDistance = null;
        
        for (var i = 0; i < MAX_BARS; i++) {
            _cadenceHistory[i] = null;
        }
        for (var i = 0; i < _chartDuration; i++) {
            _cadenceBarAvg[i] = null;
        }
    }

    function captureActivityMetrics() as Void {
        var info = Activity.getActivityInfo();
        
        if (info != null) {
            if (info.timerTime != null) {
                _sessionDuration = info.timerTime;
                System.println("[ACTIVITY] Duration: " + (_sessionDuration / 1000).toString() + " seconds");
            }
            
            if (info.elapsedDistance != null) {
                _sessionDistance = info.elapsedDistance;
                System.println("[ACTIVITY] Distance: " + (_sessionDistance / 100000.0).format("%.2f") + " km");
            }
            
            if (info.currentHeartRate != null) {
                // For now, use current heart rate as average (could be enhanced with history tracking)
                _avgHeartRate = info.currentHeartRate;
                _peakHeartRate = info.currentHeartRate;
                System.println("[ACTIVITY] Heart Rate: " + _avgHeartRate.toString() + " bpm");
            }
        }
    }

   function updateCadenceBarAvg() as Void {
    if (_sessionState != RECORDING) { 
        return;
    }

    var info = Activity.getActivityInfo();

    if (info == null) {
        System.println("[DEBUG] Activity info is null");
        return;
    }

   if (info.currentCadence == null) {
    System.println("[DEBUG] currentCadence is null - using test cadence 100");
    updateCadenceHistory(100.0);
    return;
}

    System.println("[DEBUG] currentCadence = " + info.currentCadence.toString());

    updateCadenceHistory(info.currentCadence.toFloat());
}

    function updateCadenceHistory(newCadence as Float) as Void {
        _cadenceHistory[_cadenceIndex] = newCadence;
        _cadenceIndex = (_cadenceIndex + 1) % MAX_BARS;
        if (_cadenceCount < MAX_BARS) { _cadenceCount++; }
      
        if (DEBUG_MODE) {
            System.println("[CADENCE] " + newCadence);
        }
        else {
            _missingCadenceCount++;
        }

        var cq = computeCadenceQualityScore();

        if (cq < 0) {
            System.println(
                "[CADENCE QUALITY] Warming up (" +
                _cadenceCount.toString() + "/" +
                MIN_CQ_SAMPLES.toString() + " samples)"
            );
        } else {
            if (DEBUG_MODE) {
                System.println("[CADENCE QUALITY] CQ = " + cq.format("%d") + "%");
            }

            _cqHistory.add(cq);

            if (_cqHistory.size() > 10) {
                _cqHistory.remove(0);
            }
        }

        if (_cadenceIndex % 60 == 0 && _cadenceIndex > 0) {
            //Logger.logMemoryStats("Runtime");
        }
    } 
    
        function computeTimeInZoneScore() as Number {

        if (_cadenceCount < MIN_CQ_SAMPLES) {
            return -1;
        }

        var minZone = getCalculatedMinCadence();
        var maxZone = getCalculatedMaxCadence();

        var inZoneCount = 0;
        var validSamples = 0;

        for (var i = 0; i < MAX_BARS; i++) {

            var c = _cadenceHistory[i];

            if (c != null) {

                validSamples++;

                if (c >= minZone && c <= maxZone) {
                    inZoneCount++;
                }
            }
        }

        if (validSamples == 0) {
            return -1;
        }

        var ratio = inZoneCount.toFloat() / validSamples.toFloat();

        return (ratio * 100).toNumber();
    }
 

    function idealCadenceCalculator() as Void {
        var referenceCadence = 0;
        var finalCadence = 0;
        var userLegLength = _userHeight * 0.53;
        var userSpeedms = _userSpeed / 3.6;
        
        switch (_userGender) {
            case Male:
                referenceCadence = (-1.268 * userLegLength) + (3.471 * userSpeedms) + 261.378;
                break;
            case Female:
                referenceCadence = (-1.190 * userLegLength) + (3.705 * userSpeedms) + 249.688;
                break;
            default:
                referenceCadence = (-1.251 * userLegLength) + (3.665 * userSpeedms) + 254.858;
                break;
        }

        referenceCadence = referenceCadence * _experienceLvl;
        referenceCadence = Math.round(referenceCadence);
        finalCadence = max(BASELINE_AVG_CADENCE,min(referenceCadence,MAX_CADENCE)).toNumber();

        _targetCadence = finalCadence;
        
        // Save the calculated cadence zones
        //saveSettings();
        
        System.println(
        "[CADENCE] Target cadence: " +
        _targetCadence.toString() + " spm"
        );    
        
        }

    function computeSmoothnessScore() as Number {
        if (_cadenceCount < MIN_CQ_SAMPLES) {
            return -1;
        }

        var totalDiff = 0.0;
        var diffCount = 0;

        for (var i = 1; i < MAX_BARS; i++) {
            var prev = _cadenceHistory[i - 1];
            var curr = _cadenceHistory[i];

            if (prev != null && curr != null) {
                totalDiff += abs(curr - prev);
                diffCount++;
            }
        }

        if (diffCount == 0) {
            return -1;
        }

        var avgDiff = totalDiff / diffCount;
        var rawScore = 100 - (avgDiff * 10);

        if (rawScore < 0) { rawScore = 0; }
        if (rawScore > 100) { rawScore = 100; }

        return rawScore;
    }

    function computeCadenceQualityScore() as Number {
        var timeInZone = computeTimeInZoneScore();
        var smoothness = computeSmoothnessScore();

        if (timeInZone < 0 || smoothness < 0) {
            return -1;
        }

        var cq = (timeInZone * 0.7) + (smoothness * 0.3);
        return cq.toNumber();
    }

    function computeCQConfidence() as String {
        if (_cadenceCount < MIN_CQ_SAMPLES) {
            return "Low";
        }

        var missingRatio = _missingCadenceCount.toFloat() /
                        (_cadenceCount + _missingCadenceCount).toFloat();

        if (missingRatio > 0.2) {
            return "Low";
        } else if (missingRatio > 0.1) {
            return "Medium";
        } else {
            return "High";
        }
    }

    function computeCQTrend() as String {
        if (_cqHistory.size() < 5) {
            return "Stable";
        }

        var first = _cqHistory[0];
        var last  = _cqHistory[_cqHistory.size() - 1];
        var delta = last - first;

        if (delta < -5) {
            return "Declining";
        } else if (delta > 5) {
            return "Improving";
        } else {
            return "Stable";
        }
    }

    function writeDiagnosticLog() as Void {
        if (!DEBUG_MODE) {
            return;
        }

        System.println("===== DIAGNOSTIC RUN SUMMARY =====");
        System.println("Final CQ: " +
            (_finalCQ != null ? _finalCQ.format("%d") + "%" : "N/A"));
        System.println("CQ Confidence: " +
            (_finalCQConfidence != null ? _finalCQConfidence : "N/A"));
        System.println("CQ Trend: " +
            (_finalCQTrend != null ? _finalCQTrend : "N/A"));
        System.println("Cadence samples collected: " + _cadenceCount.toString());
        System.println("Missing cadence samples: " + _missingCadenceCount.toString());

        var totalSamples = _cadenceCount + _missingCadenceCount;
        if (totalSamples > 0) {
            var validRatio =
                (_cadenceCount.toFloat() / totalSamples.toFloat()) * 100;
            System.println("Valid data ratio: " + validRatio.format("%d") + "%");
        }

        System.println( "Cadence range: " +
        getCalculatedMinCadence().toString() + "-" +
        getCalculatedMaxCadence().toString()
        );
        System.println("===== END DIAGNOSTIC SUMMARY =====");
    }

    function getSessionState() as SessionState {
        return _sessionState;
    }
    
    function isRecording() as Boolean {
        return _sessionState == RECORDING;
    }
    
    function isPaused() as Boolean {
        return _sessionState == PAUSED;
    }
    
    function isStopped() as Boolean {
        return _sessionState == STOPPED;
    }
    
    function isIdle() as Boolean {
        return _sessionState == IDLE;
    }

    function isActivityRecording() as Boolean {
        return _sessionState == RECORDING || _sessionState == PAUSED;
    }

       function getVibrationEnabled() as Boolean {
        return _vibrationEnabled;
    }
    function getTargetCadence() as Number {
        return _targetCadence;
    }

    function getCalculatedMinCadence() as Number {
        return (_targetCadence * 0.95).toNumber();
    }

    function getCalculatedMaxCadence() as Number {
        return (_targetCadence * 1.05).toNumber();
    }

    function setTargetCadence(value as Number) as Void {

        _targetCadence = value;

        saveSettings();

        System.println("[SETTINGS] Target cadence updated: " + value);
    }
    function setVibrationEnabled(enabled as Boolean) as Void {
        _vibrationEnabled = enabled;
    }

    function getSummaryEnabled() as Boolean {
        return _summaryEnabled;
    }

    function setSummaryEnabled(enabled as Boolean) as Void {
        _summaryEnabled = enabled;
        saveSettings();
        System.println("[SETTINGS] Summary view enabled: " + enabled.toString());
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

 function setChartDuration(value as Number) as Void {
    _chartDuration = value;

    // reset averaging buffer
    _cadenceBarAvg = new [_chartDuration];
    _cadenceAvgIndex = 0;
    _cadenceAvgCount = 0;

    // reset visible chart history too
    _cadenceHistory = new [MAX_BARS];
    _cadenceIndex = 0;
    _cadenceCount = 0;

    saveSettings();

    System.println("Chart changed to: " + getChartDuration());
    System.println("Bar count set to: " + _chartDuration.toString());
}
    
   function getChartDuration() as String {
    if (_chartDuration == 5) {
        return "15 min";
    } else if (_chartDuration == 10) {
        return "30 min";
    } else if (_chartDuration == 20) {
        return "1 hour";
    } else if (_chartDuration == 40) {
        return "2 hours";
    } else if (_chartDuration == 3) {
        return "15 min";
    } else if (_chartDuration == 6) {
        return "30 min";
    } else if (_chartDuration == 13) {
        return "1 hour";
    } else if (_chartDuration == 26) {
        return "2 hours";
    }

    return "Unknown";
}
    
    function getUserGender() as String {
        return _userGender;
    }

    function setUserGender(value as Number) as Void {
        _userGender = value;
        //saveSettings();
    }

    function getUserLegLength() as Float {
        return _userHeight * 0.53;
    }

    function setUserHeight(value as Number) as Void {
        _userHeight = value;
        //saveSettings();
    }

    function getUserHeight() as Number {
        return _userHeight;
    }

    function getUserSpeed() as Float {
        return _userSpeed;
    }

    function setUserSpeed(value as Float) as Void {
        _userSpeed = value;
        //saveSettings();
    }

    function getExperienceLvl() as Number {
        return _experienceLvl;
    }

    function setExperienceLvl(value as Float) as Void {
        _experienceLvl = value;
        //saveSettings();
    }

    function min(a,b){
        return (a < b) ? a : b;
    }

    function max(a,b){
        return (a > b) ? a : b;
    }

    function abs(x) {
        return (x < 0) ? -x : x;
    }

    function getFinalCadenceQuality() {
        return _finalCQ;
    }

    function getFinalCQConfidence() {
        return _finalCQConfidence;
    }

    function getFinalCQTrend() {
        return _finalCQTrend;
    }
    function getSessionDuration() {
    return _sessionDuration;
    }

// --- SETTINGS MANAGEMENT ---

    function saveSettings() {
    var s = Application.Storage;
    
    s.setValue("target_cad", _targetCadence);
    s.setValue("u_height", _userHeight);
    s.setValue("u_speed", _userSpeed);
    s.setValue("u_exp", _experienceLvl);
    s.setValue("u_gen", _userGender);
    s.setValue("u_dur", _chartDuration);
    s.setValue(PROP_SUMMARY_ENABLED, _summaryEnabled);
    
    System.println("--- DISK SYNC COMPLETE ---");
}

function loadSettings() {
    var s = Application.Storage;
    var val;
    val = s.getValue("target_cad");

    if (val != null) {
    _targetCadence = val;
    }

    val = s.getValue("u_height"); if (val != null) { _userHeight = val; }
    val = s.getValue("u_speed"); if (val != null) { _userSpeed = val; }
    val = s.getValue("u_exp"); if (val != null) { _experienceLvl = val; }
    val = s.getValue("u_gen"); if (val != null) { _userGender = val; }
    val = s.getValue(PROP_SUMMARY_ENABLED); if (val != null) { _summaryEnabled = val; }
    val = s.getValue("u_dur");

if (val != null) {
    if (val == 3) {
        _chartDuration = 5;
    } else if (val == 6) {
        _chartDuration = 10;
    } else if (val == 13) {
        _chartDuration = 20;
    } else if (val == 26) {
        _chartDuration = 40;
    } else {
        _chartDuration = val;
    }
}

    _cadenceBarAvg = new [_chartDuration];
    _cadenceAvgIndex = 0;
    _cadenceAvgCount = 0;

    System.println(
    "[CADENCE] Target: " +
    _targetCadence.toString()
);


    // function getSessionDuration() as Number {
    //     if (_sessionStartTime == null) {
    //         return 0;
    //     }
        
    //     var currentTime = System.getTimer();
    //     var totalTime = currentTime - _sessionStartTime - _sessionPausedTime;
        
    //     if (_sessionState == PAUSED && _lastPauseTime != null) {
    //         totalTime -= (currentTime - _lastPauseTime);
    //     }
        
    //     return totalTime / 1000;
    // }
}

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SimpleView(), new SimpleViewDelegate() ];
    }

    // -----------------------
    // Summary Statistics Methods
    // -----------------------

    function getAverageCadence() as Float {
        if (_cadenceCount == 0) {
            return 0.0;
        }

        var total = 0.0;
        var validSamples = 0;

        for (var i = 0; i < MAX_BARS; i++) {
            var c = _cadenceHistory[i];
            if (c != null) {
                total += c;
                validSamples++;
            }
        }

        if (validSamples == 0) {
            return 0.0;
        }

        return total / validSamples;
    }

    function getTimeInZonePercentage() as Number {
        return computeTimeInZoneScore();
    }

    function getMinCadenceFromHistory() as Number {
        var minCad = null;

        for (var i = 0; i < MAX_BARS; i++) {
            var c = _cadenceHistory[i];
            if (c != null) {
                if (minCad == null || c < minCad) {
                    minCad = c;
                }
            }
        }

        return (minCad != null) ? minCad.toNumber() : 0;
    }

    function getMaxCadenceFromHistory() as Number {
        var maxCad = null;

        for (var i = 0; i < MAX_BARS; i++) {
            var c = _cadenceHistory[i];
            if (c != null) {
                if (maxCad == null || c > maxCad) {
                    maxCad = c;
                }
            }
        }

        return (maxCad != null) ? maxCad.toNumber() : 0;
    }

    function hasValidSummaryData() as Boolean {
        return Activity.getActivityInfo() != null;
    }

   function getfinalQC() as String {
    if (_finalCQ == null) {
        return "N/A";
    } else {
        return _finalCQ.format("%d") + "%";
    }
}

    // Activity metrics getters
    /*
    function getSessionDuration() {
        return _sessionDuration;
    }*/

    function getSessionDistance() {
        return _sessionDistance;
    }

    function getAvgHeartRate() {
        return _avgHeartRate;
    }

    function getPeakHeartRate() {
        return _peakHeartRate;
    }

    function getChartBarCount() as Number {
        return _chartDuration;
    }
}

function getApp() as GarminApp {
    return Application.getApp() as GarminApp;
}

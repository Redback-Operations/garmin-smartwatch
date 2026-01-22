import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.System;


class GarminApp extends Application.AppBase {
    const MAX_BARS = 280;
    const BASELINE_AVG_CADENCE = 160;
    const MAX_CADENCE = 190;
    const MIN_CQ_SAMPLES = 30;
    const DEBUG_MODE = true;

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
        FifteenminChart = 3,
        ThirtyminChart = 6, 
        OneHourChart = 13,
        TwoHourChart = 26
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

    private var _userHeight = 170;
    private var _userSpeed = 10;
    private var _experienceLvl = Beginner;
    private var _userGender = Male;
    private var _chartDuration = ThirtyminChart as Number;

    private var _idealMinCadence = 120;
    private var _idealMaxCadence = 150;

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
    
    private var _sessionStartTime = null;
    private var _sessionPausedTime = 0;
    private var _lastPauseTime = null;


    function initialize() {
        AppBase.initialize();
        System.println("[INFO] App initialized");
        activitySession = null;
    }

    function onStart(state as Dictionary?) as Void {
        System.println("[INFO] App starting");
        Logger.logMemoryStats("Startup");
        
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
        
        Logger.logMemoryStats("Shutdown");
    }

    function startRecording() as Void {
        if (_sessionState == RECORDING) {
            System.println("[INFO] Already recording");
            return;
        }

        System.println("[INFO] Starting activity session");

        // Create and start Garmin activity session
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
        _sessionStartTime = System.getTimer();
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

    function saveSession() as Void {
        if (_sessionState != STOPPED) {
            System.println("[INFO] Cannot save - session not stopped");
            return;
        }

        System.println("[INFO] Saving activity session");
        
        // Save Garmin activity session
        if (activitySession != null) {
            activitySession.save();
            System.println("[INFO] Garmin activity session saved to FIT file");
            activitySession = null;
        }
        
        var totalTime = 0;
        if (_sessionStartTime != null) {
            totalTime = System.getTimer() - _sessionStartTime - _sessionPausedTime;
        }
        
        System.println("===== SESSION SAVED =====");
        System.println("Duration: " + (totalTime / 1000).format("%d") + " seconds");
        System.println("Cadence samples: " + _cadenceCount.toString());
        System.println("Final CQ: " + (_finalCQ != null ? _finalCQ.format("%d") + "%" : "N/A"));
        System.println("========================");
        
        resetSession();
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
        _sessionStartTime = null;
        _sessionPausedTime = 0;
        _lastPauseTime = null;
        
        for (var i = 0; i < MAX_BARS; i++) {
            _cadenceHistory[i] = null;
        }
        for (var i = 0; i < _chartDuration; i++) {
            _cadenceBarAvg[i] = null;
        }
    }

    function updateCadenceBarAvg() as Void {
        // CRITICAL: Only collect data when RECORDING
        if (_sessionState != RECORDING) { 
            return;
        }
      
        var info = Activity.getActivityInfo();
    
        if (info != null && info.currentCadence != null) {
            var newCadence = info.currentCadence;
            _cadenceBarAvg[_cadenceAvgIndex] = newCadence.toFloat();
            _cadenceAvgIndex = (_cadenceAvgIndex + 1) % _chartDuration;
            if (_cadenceAvgCount < _chartDuration) { 
                _cadenceAvgCount++; 
            }
            else {
                var barAvg = 0.0;
                for(var i = 0; i < _chartDuration; i++){
                    barAvg += _cadenceBarAvg[i];
                }
                updateCadenceHistory(barAvg / _chartDuration);
                _cadenceAvgCount = 0;
            }
        }
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
            Logger.logMemoryStats("Runtime");
        }
    } 

    function computeTimeInZoneScore() as Number {
        if (_cadenceCount < MIN_CQ_SAMPLES) {
            return -1;
        }

        var minZone = _idealMinCadence;
        var maxZone = _idealMaxCadence;

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

        _idealMaxCadence = finalCadence + 5;
        _idealMinCadence = finalCadence - 5;
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

        System.println("Ideal cadence range: " +
            _idealMinCadence.toString() + "-" +
            _idealMaxCadence.toString());
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

    function getMinCadence() as Number {
        return _idealMinCadence;
    }
    
    function getMaxCadence() as Number {
        return _idealMaxCadence;    
    }
    
    function setMinCadence(value as Number) as Void {
        _idealMinCadence = value;
    }

    function setMaxCadence(value as Number) as Void {
        _idealMaxCadence = value;
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
        System.println(CHART_ENUM_NAMES[_chartDuration] + " selected.");
    }
    
    function getChartDuration() as String{
        return CHART_ENUM_NAMES[_chartDuration];
    }
    
    function getUserGender() as String {
        return _userGender;
    }

    function setUserGender(value as Number) as Void {
        _userGender = value;
    }

    function getUserLegLength() as Float {
        return _userHeight * 0.53;
    }

    function setUserHeight(value as Number) as Void {
        _userHeight = value;
    }

    function getUserHeight() as Number {
        return _userHeight;
    }

    function getUserSpeed() as Float {
        return _userSpeed;
    }

    function setUserSpeed(value as Float) as Void {
        _userSpeed = value;
    }

    function getExperienceLvl() as Number {
        return _experienceLvl;
    }

    function setExperienceLvl(value as Float) as Void {
        _experienceLvl = value;
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

    function getSessionDuration() as Number {
        if (_sessionStartTime == null) {
            return 0;
        }
        
        var currentTime = System.getTimer();
        var totalTime = currentTime - _sessionStartTime - _sessionPausedTime;
        
        if (_sessionState == PAUSED && _lastPauseTime != null) {
            totalTime -= (currentTime - _lastPauseTime);
        }
        
        return totalTime / 1000;
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SimpleView(), new SimpleViewDelegate() ];
    }
}

function getApp() as GarminApp {
    return Application.getApp() as GarminApp;
}

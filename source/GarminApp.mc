import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Activity;
import Toybox.System;


class GarminApp extends Application.AppBase {
    const MAX_BARS = 280;
    //const MAX_BARS_DISPLAY = 0;
    const BASELINE_AVG_CADENCE = 160;
    const MAX_CADENCE = 190;
    const MIN_CQ_SAMPLES = 30;
    const DEBUG_MODE = true;

    var globalTimer;
    var isRecording as Boolean = false;

    enum { //each chart corresponds to a difference bar duration average (in seconds)
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

    //default value (can change in settings)
    private var _userHeight = 170;//>>cm
    private var _userSpeed = 3.8;//>>m/s
    private var _experienceLvl = Beginner;
    private var _userGender = Male;
    private var _chartDuration = ThirtyminChart;

    private var _idealMinCadence = 80;
    private var _idealMaxCadence = 100;

    private var _cadenceHistory as Array<Float?> = new [MAX_BARS]; // Store session's cadence
    private var _cadenceIndex = 0;
    private var _cadenceCount = 0;
     
    private var _cadenceBarAvg as Array<Float?> = new [_chartDuration]; // Store data points for display
    private var _cadenceAvgIndex = 0;
    private var _cadenceAvgCount = 0;
  
    private var _finalCQ = null;
    private var _missingCadenceCount = 0;
    private var _finalCQConfidence = null;
    private var _finalCQTrend = null;
    private var _cqHistory as Array<Number> = [];


    function initialize() {
        AppBase.initialize();
        System.println("[INFO] App initialized");
    }

    function onStart(state as Dictionary?) as Void {
        System.println("[INFO] App starting");
        
        // Log memory on startup
        Logger.logMemoryStats("Startup");
        
        globalTimer = new Timer.Timer();
        globalTimer.start(method(:updateCadenceBarAvg),1000,true);
        idealCadenceCalculator();
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

    function startRecording() as Void {

        if (isRecording) {return;}

        System.println("[INFO] Starting cadence monitoring");

        _finalCQ = null;
        _finalCQConfidence = null;
        _finalCQTrend = null;
        _cqHistory = [];
        _cadenceCount = 0;
        _missingCadenceCount = 0;

        isRecording = true; 
    }


    function stopRecording() as Void {

        if (!isRecording) {return;}

        System.println("[INFO] Stopping cadence monitoring");

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

        isRecording = false;
    }

    function updateCadenceBarAvg() as Void {
      //if (!isRecording) { return;} // ignore samples when not actively monitoring
      
      var info = Activity.getActivityInfo();
    
        if (info != null && info.currentCadence != null) {
            var newCadence = info.currentCadence;
            _cadenceBarAvg[_cadenceAvgIndex] = newCadence.toFloat();
            // Add to circular buffer
            _cadenceAvgIndex = (_cadenceAvgIndex + 1) % _chartDuration;
            if (_cadenceAvgCount < _chartDuration) { 
                _cadenceAvgCount++; 
            }
            else //calculate avg
            {
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
        // Add to circular buffer
        _cadenceIndex = (_cadenceIndex + 1) % MAX_BARS;
        if (_cadenceCount < MAX_BARS) { _cadenceCount++; }
      
        if (DEBUG_MODE) {
            System.println("[CADENCE] " + newCadence);
        }
        else {
            // Track missing cadence samples (sensor dropouts)
            _missingCadenceCount++;
        }

        // ----- Cadence Quality computation -----
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

            // Record CQ history for trend analysis 
            _cqHistory.add(cq);

            // Keep sliding window small and recent
            if (_cqHistory.size() > 10) {
                _cqHistory.remove(0);
            }
        }

        // ----- Memory logging (approx once per minute) -----
        if (_cadenceIndex % 60 == 0 && _cadenceIndex > 0) {
            Logger.logMemoryStats("Runtime");
        }
      
} 



    // Cadence Quality
    function computeTimeInZoneScore() as Number {

        // Not enough data yet
        if (_cadenceCount < MIN_CQ_SAMPLES) {
            return -1; // sentinel value meaning "not ready"
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
        
        //reference cadence
        switch (_userGender) {
            case Male:
                referenceCadence = (-1.268 * userLegLength) + (3.471 * _userSpeed) + 261.378;
                break;
            case Female:
                referenceCadence = (-1.190 * userLegLength) + (3.705 * _userSpeed) + 249.688;
                break;
            default:
                referenceCadence = (-1.251 * userLegLength) + (3.665 * _userSpeed) + 254.858;
                break;
        }

        //experience adjustment
        referenceCadence = referenceCadence * _experienceLvl;

        //apply threshold
        referenceCadence = Math.round(referenceCadence);
        finalCadence = max(BASELINE_AVG_CADENCE,min(referenceCadence,MAX_CADENCE)).toNumber();

        //set new min max ideal cadence 
        _idealMaxCadence = finalCadence + 5;
        _idealMinCadence = finalCadence - 5;
    }

    function computeSmoothnessScore() as Number {

        // Not enough data yet
        if (_cadenceCount < MIN_CQ_SAMPLES) {
            return -1; // not ready
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

        /*
            Interpret avgDiff:
            - ~0–1   → very smooth
            - ~2–3   → normal
            - >5     → erratic
        */

        var rawScore = 100 - (avgDiff * 10);

        // Clamp to 0–100
        if (rawScore < 0) { rawScore = 0; }
        if (rawScore > 100) { rawScore = 100; }

        return rawScore;
    }

    function computeCadenceQualityScore() as Number {

        var timeInZone = computeTimeInZoneScore();
        var smoothness = computeSmoothnessScore();

        // Not ready yet
        if (timeInZone < 0 || smoothness < 0) {
            return -1;
        }

        // Weighted combination
        var cq =
            (timeInZone * 0.7) +
            (smoothness * 0.3);

        return cq.toNumber();
    }


    function computeCQConfidence() as String {

        // Not enough data → low confidence
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

            System.println("Valid data ratio: " +
                validRatio.format("%d") + "%");
        }

        System.println("Ideal cadence range: " +
            _idealMinCadence.toString() + "-" +
            _idealMaxCadence.toString());

        System.println("===== END DIAGNOSTIC SUMMARY =====");
    }


    //set and get functions
    function isActivityRecording() as Boolean {
        return isRecording;
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

    function getChartDuration() as String{
        return CHART_ENUM_NAMES[_chartDuration];
    }

    function setChartDuration(value as String) as Void {
        _chartDuration = value;
    }
    
    function getUserGender() as String {
        return _userGender;
    }

    function setUserGender(value as String) as Void {
        _userGender = value;
    }

    function getUserLegLength() as Float {
        return _userHeight * 0.53;
    }

    function setUserHeight(value as Number) as Void {
        _userHeight = value;
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

    function setExperienceLvl(value as Number) as Void {
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


    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SimpleView(), new SimpleViewDelegate() ];
    }
}

function getApp() as GarminApp {
    return Application.getApp() as GarminApp;
}



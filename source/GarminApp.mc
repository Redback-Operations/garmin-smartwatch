import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GarminApp extends Application.AppBase {
    const MAX_BARS = 280;
    //const MAX_BARS_DISPLAY = 0;
    const BASELINE_AVG_CADENCE = 160;
    const MAX_CADENCE = 190;

    var globalTimer;

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

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        globalTimer = new Timer.Timer();
        globalTimer.start(method(:updateCadenceBarAvg),1000,true);
        idealCadenceCalculator();
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if(globalTimer != null){
            globalTimer.stop();
            globalTimer = null;
        }
    }


    function updateCadenceBarAvg() as Void {
        var info = Activity.getActivityInfo();
        
        //var zoneState = null;
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


    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new SimpleView(), new SimpleViewDelegate() ];
    }

    
}
function getApp() as GarminApp {
    return Application.getApp() as GarminApp;
}

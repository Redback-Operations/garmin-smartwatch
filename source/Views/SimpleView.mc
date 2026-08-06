import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;
import Toybox.Attention;

class SimpleView extends WatchUi.View {

    // UI Drawables
    private var _cadenceDisplay;
    private var _cadenceZoneDisplay;
    private var _heartrateDisplay;
    private var _distanceDisplay;
    private var _timeDisplay;
    private var _paceDisplay;
    
    // Logic & Timer Variables
    private var _refreshTimer;
    private var _lastZoneState = 0; 
    private var _alertStartTime = null;
    private var _alertDuration = 180000; // 3 minutes
    private var _alertInterval = 30000; // 30 seconds
    private var _lastAlertTime = 0;
    
    private var _pendingSecondVibe = false;
    private var _secondVibeTime = 0;

    function initialize() {
        WatchUi.View.initialize();
    }
    
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        
        // Link UI variables to layout IDs
        _cadenceDisplay = findDrawableById("cadence_text");
        _cadenceZoneDisplay = findDrawableById("cadence_zone");
        _heartrateDisplay = findDrawableById("heartrate_text");
        _distanceDisplay = findDrawableById("distance_text"); // Restored
        _timeDisplay = findDrawableById("time_text");
        _paceDisplay = findDrawableById("pace_text"); 

        var _spmLabel = findDrawableById("spm_label") as WatchUi.Text;
        if (_spmLabel != null) { _spmLabel.setText("SPM"); }
    }

    function onShow() as Void {
        // Start the logic loop and keep it alive across views
        if (_refreshTimer == null) {
            _refreshTimer = new Timer.Timer();
            _refreshTimer.start(method(:refreshScreen), 1000, true);
        }
    }

    function onHide() as Void {
// CRITICAL: Stop the timer to prevent "Timer Limit" crashes
        if (_refreshTimer != null) {
            _refreshTimer.stop();
            _refreshTimer = null;
        }
    }

    // --- Logic Loop (The "Heartbeat") ---
    function refreshScreen() as Void {
        var info = Activity.getActivityInfo();
        
        // 1. Update internal state (Zone checking)
        updateCadenceLogic(info);
        
        // 2. Check for recurring alerts
        checkAndTriggerAlerts();
        
        // 3. Request UI draw
        WatchUi.requestUpdate();
    }

    // --- Drawing Loop (The "Face") ---
    function onUpdate(dc as Dc) as Void {
        updateDisplayStrings();
        checkPendingVibration();
        
        View.onUpdate(dc); 
        drawDividers(dc);

        drawRecordingIndicator(dc);
    }

    function updateCadenceLogic(info) as Void {
        var minZone = Application.getApp().getCalculatedMinCadence();
        var maxZone = Application.getApp().getCalculatedMaxCadence();
        
        var newZoneState = 0;
        if (info != null && info.currentCadence != null) {
            var c = info.currentCadence;
            if (c < minZone) { newZoneState = -1; }
            else if (c > maxZone) { newZoneState = 1; }
        }

        if (newZoneState != _lastZoneState) {
            if (newZoneState != 0) {
                _alertStartTime = System.getTimer();
                _lastAlertTime = System.getTimer();
            } else {
                _alertStartTime = null;
            }
            _lastZoneState = newZoneState;
        }
    }

    function checkAndTriggerAlerts() as Void {
        if (_alertStartTime == null) { return; }
        
        var currentTime = System.getTimer();
        if (currentTime - _alertStartTime >= _alertDuration) {
            _alertStartTime = null;
            return;
        }
        
        if (currentTime - _lastAlertTime >= _alertInterval) {
            _lastAlertTime = currentTime;

            var app = Application.getApp();
            var isVibrationOn = app.getVibrationEnabled();
            var msg = (_lastZoneState == -1) ? "Increase Cadence" : "Decrease Cadence";

            WatchUi.pushView(
                new CadenceAlertView(msg, isVibrationOn, "SimpleView"),
                new CadenceAlertDelegate(),
                WatchUi.SLIDE_IMMEDIATE
            );

            if (isVibrationOn) {
                if (_lastZoneState == -1) { triggerSingleVibration(); }
                else { triggerDoubleVibration(); }
            }
        }
    }

    function updateDisplayStrings() as Void {
        var info = Activity.getActivityInfo();
        var app = Application.getApp();
        
        // Cadence
        if (_cadenceDisplay != null) {
            _cadenceDisplay.setText(info != null && info.currentCadence != null ? info.currentCadence.toString() : "--");
        }

        // Zone Info
        if (_cadenceZoneDisplay != null) {
            var min = app.getCalculatedMinCadence();
            var max = app.getCalculatedMaxCadence();
            _cadenceZoneDisplay.setText("(" + min + "-" + max + ")");
        }

        // Heartrate
        if (_heartrateDisplay != null) {
            _heartrateDisplay.setText(info != null && info.currentHeartRate != null ? info.currentHeartRate.toString() : "--");
        }

        // --- DISTANCE (RESTORED) ---
        if (_distanceDisplay != null) {
            if (info != null && info.elapsedDistance != null) {
                var distanceKm = info.elapsedDistance / 1000.0; // Meters to Kilometers
                _distanceDisplay.setText(distanceKm.format("%.2f") + " KM");
            } else {
                _distanceDisplay.setText("-- KM");
            }
        }

        // Time
        if (_timeDisplay != null && info != null && info.timerTime != null) {
            var s = info.timerTime / 1000;
            _timeDisplay.setText((s/3600).format("%02d") + ":" + ((s%3600)/60).format("%02d") + ":" + (s%60).format("%02d"));
        }
        
        // Pace
        if (_paceDisplay != null && info != null && info.currentSpeed != null && info.currentSpeed > 0) {
            var pace = (1000.0 / info.currentSpeed).toNumber();
            _paceDisplay.setText((pace/60).format("%d") + ":" + (pace%60).format("%02d") + " min/km");
        } else if (_paceDisplay != null) {
            _paceDisplay.setText("--:-- min/km");
        }
    }

    // --- Helpers ---
    function checkPendingVibration() as Void {
        if (_pendingSecondVibe && System.getTimer() >= _secondVibeTime) {
            if (Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(50, 200)]);
            }
            _pendingSecondVibe = false;
        }
    }
    
    function triggerSingleVibration() as Void {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(50, 200)]);
        }
    }
    
    function triggerDoubleVibration() as Void {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(50, 200)]);
            _pendingSecondVibe = true;
            _secondVibeTime = System.getTimer() + 240;
        }
    }

    function drawRecordingIndicator(dc as Dc) as Void {
        var app = Application.getApp();
        if (app.isActivityRecording()) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(dc.getWidth() - 15, 15, 8);
        }

        drawVibrationModeIndicator(dc);
    }

    function drawVibrationModeIndicator(dc as Dc) as Void {
    var app = Application.getApp();
    var vibrationOn = app.getVibrationEnabled();

    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

    if (vibrationOn) {
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() - 30,
            Graphics.FONT_XTINY,
            "VIB ON",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    } else {
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() - 30,
            Graphics.FONT_XTINY,
            "VIB OFF",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}

    function drawDividers(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(20, h * 0.22, w - 20, h * 0.22);
        dc.drawLine(20, h * 0.43, w - 20, h * 0.43);
        dc.drawLine(20, h * 0.60, w - 20, h * 0.60);
        dc.drawLine(20, h * 0.78, w - 20, h * 0.78);
    }
}
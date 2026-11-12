import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;
import Toybox.Attention;

class SimpleView extends WatchUi.View {

    const MAIN_VIBRATION_ICON_BOTTOM_MARGIN = 0.05;

    // UI Drawables
    private var _cadenceDisplay;
    private var _cadencePercentDisplay;
    private var _cadenceZoneDisplay;
    private var _cadenceRangeDisplay;
    private var _heartrateDisplay;
    private var _distanceDisplay;
    private var _timeDisplay;
    private var _paceDisplay;
    private var _paceIcon;
    private var _heartRateIcon;
    private var _vibrationOnIcon;
    private var _vibrationOffIcon;
    
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
        var compact = dc.getWidth() < 300;
        
        // Link UI variables to layout IDs
        _cadenceDisplay = findDrawableById("cadence_text");
        _cadencePercentDisplay = findDrawableById("cadence_percent");
        _cadenceZoneDisplay = findDrawableById("cadence_zone");
        _cadenceRangeDisplay = findDrawableById("cadence_range");
        _heartrateDisplay = findDrawableById("heartrate_text");
        _distanceDisplay = findDrawableById("distance_text"); // Restored
        _timeDisplay = findDrawableById("time_text");
        _paceDisplay = findDrawableById("pace_text");
        _paceIcon = WatchUi.loadResource(
            compact ? Rez.Drawables.PaceIconCompact : Rez.Drawables.PaceIcon
        );
        _heartRateIcon = WatchUi.loadResource(
            compact ? Rez.Drawables.MainHeartRateIconCompact : Rez.Drawables.MainHeartRateIcon
        );
        _vibrationOnIcon = WatchUi.loadResource(
            compact ? Rez.Drawables.MainVibrationOnIconCompact : Rez.Drawables.MainVibrationOnIcon
        );
        _vibrationOffIcon = WatchUi.loadResource(
            compact ? Rez.Drawables.MainVibrationOffIconCompact : Rez.Drawables.MainVibrationOffIcon
        );

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
        var app = Application.getApp();
        
        // Pause freeze: stop all runtime calculations while not recording.
        // This freezes cadence processing and vibration alerts until Resume.
        if (!app.isRecording()) {
            WatchUi.requestUpdate();
            return;
        }

        if (app.isFeedbackHidden()) {
            // Hidden windows still record cadence in GarminApp, but all cadence
            // guidance and queued vibration feedback are suppressed here.
            _alertStartTime = null;
            _lastZoneState = 0;
            _pendingSecondVibe = false;
            WatchUi.requestUpdate();
            return;
        }
        
        // 1. Update internal state (Zone checking)
        updateCadenceLogic(info);
        
        // 2. Check for recurring alerts
        checkAndTriggerAlerts();
        
        // 3. Request UI draw
        WatchUi.requestUpdate();
    }

    // --- Drawing Loop (The "Face") ---
    function onUpdate(dc as Dc) as Void {
        var app = Application.getApp();

        if (app.isFeedbackHidden() && app.shouldShowFeedbackHiddenNotice()) {
            drawFeedbackHiddenIndicator(dc, app);
            return;
        }

        updateDisplayStrings();
        checkPendingVibration();

        // Layout labels do not erase their previous pixels on every device.
        // Clear first so changing values never ghost or overlap one another.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        View.onUpdate(dc); 
        drawHeartRateIcon(dc);
        drawPaceIcon(dc);
        drawDividers(dc);
        drawVibrationStatusIcon(dc);
        drawRecordingIndicator(dc);
    }

    function drawFeedbackHiddenIndicator(dc as Dc, app) as Void {
        FeedbackHiddenRenderer.draw(dc, app);
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
        var minCadence = app.getCalculatedMinCadence();
        var maxCadence = app.getCalculatedMaxCadence();
        var cadence = info != null ? info.currentCadence : null;

        // Cadence and its live quality score.
        if (_cadenceDisplay != null) {
            _cadenceDisplay.setText(cadence != null ? cadence.toString() + " SPM" : "-- SPM");
        }

        if (_cadencePercentDisplay != null) {
            var cadenceQuality = app.computeCadenceQualityScore();
            _cadencePercentDisplay.setText((cadenceQuality < 0 ? 0 : cadenceQuality).toString() + "%");
        }

        if (_cadenceZoneDisplay != null) {
            var zoneText = "in range";
            if (cadence != null && cadence < minCadence) {
                zoneText = "below";
            } else if (cadence != null && cadence > maxCadence) {
                zoneText = "above";
            }
            _cadenceZoneDisplay.setText(zoneText);
        }

        if (_cadenceRangeDisplay != null) {
            _cadenceRangeDisplay.setText(
                minCadence.toString() + "-" + maxCadence.toString() + " spm"
            );
        }

        // Heartrate
        if (_heartrateDisplay != null) {
            _heartrateDisplay.setText(info != null && info.currentHeartRate != null ? info.currentHeartRate.toString() : "--");
        }

        // Distance
        if (_distanceDisplay != null) {
            if (info != null && info.elapsedDistance != null) {
                var distanceKm = info.elapsedDistance / 1000.0; // Meters to Kilometers
                _distanceDisplay.setText(distanceKm.format("%.2f") + " KM");
            } else {
                _distanceDisplay.setText("-- KM");
            }
        }

        // Time
        if (_timeDisplay != null) {
            if (info != null && info.timerTime != null) {
                var s = info.timerTime / 1000;
                _timeDisplay.setText((s/3600).format("%02d") + ":" + ((s%3600)/60).format("%02d") + ":" + (s%60).format("%02d"));
            } else {
                _timeDisplay.setText("00:00:00");
            }
        }
        
        // Pace uses the average of up to five most recent active seconds.
        if (_paceDisplay != null) {
            var averageSpeed = Application.getApp().getAverageRecentSpeed();

            if (averageSpeed != null && averageSpeed > 0) {
                var pace = (1000.0 / averageSpeed).toNumber();
                _paceDisplay.setText(
                    (pace / 60).format("%d") + ":" +
                    (pace % 60).format("%02d") + " min/km"
                );
            } else {
                _paceDisplay.setText("--:-- min/km");
            }
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
            var radius = (dc.getWidth() * 0.015).toNumber();
            if (radius < 3) { radius = 3; }
            if (radius > 6) { radius = 6; }
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(
                (dc.getWidth() * 0.82).toNumber(),
                (dc.getHeight() * 0.12).toNumber(),
                radius
            );
        }
    }

    function drawPaceIcon(dc as Dc) as Void {
        if (_paceIcon == null) { return; }

        dc.drawBitmap(
            (dc.getWidth() * 0.17).toNumber(),
            (dc.getHeight() * 0.70).toNumber(),
            _paceIcon
        );
    }

    function drawHeartRateIcon(dc as Dc) as Void {
        if (_heartRateIcon == null) { return; }

        // Align the icon's visual centre with the heart-rate text baseline.
        dc.drawBitmap(
            (dc.getWidth() * 0.15).toNumber(),
            (dc.getHeight() * 0.50).toNumber(),
            _heartRateIcon
        );
    }

    function drawVibrationStatusIcon(dc as Dc) as Void {
        var app = Application.getApp();
        var icon = app.getVibrationEnabled() ? _vibrationOnIcon : _vibrationOffIcon;
        if (icon == null) { return; }

        // The x position is derived from the screen width so the icon remains
        // centred across every supported round watch size.
        var iconWidth = icon.getWidth();
        var iconHeight = icon.getHeight();
        var x = ((dc.getWidth() - iconWidth) / 2).toNumber();
        var bottomMargin = (dc.getHeight() * MAIN_VIBRATION_ICON_BOTTOM_MARGIN).toNumber();
        var y = dc.getHeight() - iconHeight - bottomMargin;

        dc.drawBitmap(x, y, icon);
    }

    function drawDividers(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var inset = (w * 0.10).toNumber();
        dc.drawLine(inset, (h * 0.23).toNumber(), w - inset, (h * 0.23).toNumber());
        dc.drawLine(inset, (h * 0.48).toNumber(), w - inset, (h * 0.48).toNumber());
        dc.drawLine(inset, (h * 0.63).toNumber(), w - inset, (h * 0.63).toNumber());
    }
}

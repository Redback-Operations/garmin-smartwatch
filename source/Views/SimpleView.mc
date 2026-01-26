import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;
import Toybox.Attention;

class SimpleView extends WatchUi.View {

    private var _cadenceDisplay;
    private var _refreshTimer;
    private var _heartrateDisplay;
    private var _distanceDisplay;
    private var _timeDisplay;
    private var _cadenceZoneDisplay;
    private var _lastZoneState = 0; // -1 = below, 0 = inside, 1 = above
    private var _cqDisplay;
    private var _hardcoreDisplay;
    
    // Vibration alert tracking (no extra timers needed!)
    private var _alertStartTime = null;
    private var _alertDuration = 180000; // 3 minutes in milliseconds
    private var _alertInterval = 30000; // 30 seconds in milliseconds
    private var _lastAlertTime = 0;
    private var _pendingSecondVibe = false;
    private var _secondVibeTime = 0;

    function initialize() {
        View.initialize();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _refreshTimer = new Timer.Timer();
        _refreshTimer.start(method(:refreshScreen), 1000, true);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        //update the display for current cadence
        displayCadence();
        
        // Check for pending second vibration
        checkPendingVibration();
        
        // Draw recording indicator
        drawRecordingIndicator(dc);
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        if (_refreshTimer != null) {
            _refreshTimer.stop();
            _refreshTimer = null;
        }
        // Reset alert state
        _alertStartTime = null;
        _lastAlertTime = 0;
    }

    function refreshScreen() as Void{
        WatchUi.requestUpdate();
    }
    
    function checkPendingVibration() as Void {
        if (_pendingSecondVibe) {
            var currentTime = System.getTimer();
            if (currentTime >= _secondVibeTime) {
                // Trigger second vibration
                if (Attention has :vibrate) {
                    var vibeData = [new Attention.VibeProfile(50, 200)];
                    Attention.vibrate(vibeData);
                }
                _pendingSecondVibe = false;
            }
        }
    }
    
    function triggerSingleVibration() as Void {
        if (Attention has :vibrate) {
            var vibeData = [new Attention.VibeProfile(50, 200)];
            Attention.vibrate(vibeData);
        }
    }
    
    function triggerDoubleVibration() as Void {
        if (Attention has :vibrate) {
            // First vibration
            var vibeData = [new Attention.VibeProfile(50, 200)];
            Attention.vibrate(vibeData);
            
            // Schedule second vibration after 240ms
            _pendingSecondVibe = true;
            _secondVibeTime = System.getTimer() + 240;
        }
    }
    
    function checkAndTriggerAlerts() as Void {
        // Only check if we're in an alert period
        if (_alertStartTime == null) {
            return;
        }
        
        var currentTime = System.getTimer();
        var elapsed = currentTime - _alertStartTime;
        
        // Stop alerting after 3 minutes
        if (elapsed >= _alertDuration) {
            _alertStartTime = null;
            _lastAlertTime = 0;
            return;
        }
        
        // Check if it's time for the next alert (every 30 seconds)
        var timeSinceLastAlert = currentTime - _lastAlertTime;
        if (timeSinceLastAlert >= _alertInterval) {
            _lastAlertTime = currentTime;
            
            // Trigger the appropriate vibration
            if (_lastZoneState == -1) {
                triggerSingleVibration();
            } else if (_lastZoneState == 1) {
                triggerDoubleVibration();
            }
        }
    }

    function drawRecordingIndicator(dc as Dc) as Void {
        var app = getApp();
        
        if (app.isActivityRecording()) {
            // Draw a red recording indicator in top-right corner
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            var width = dc.getWidth();
            var radius = 8;
            dc.fillCircle(width - 15, 15, radius);
            
            // Add "REC" text next to the indicator
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width - 35, 5, Graphics.FONT_TINY, "REC", Graphics.TEXT_JUSTIFY_RIGHT);
        } else {
            // Draw instruction text at bottom
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            var width = dc.getWidth();
            var height = dc.getHeight();
            dc.drawText(width / 2, height - 25, Graphics.FONT_TINY, "Press SELECT to start", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function displayCadence() as Void{
        var info = Activity.getActivityInfo();
        

        if (info != null && info.currentCadence != null){
            _cadenceDisplay.setText(info.currentCadence.toString());
        }else{
            _cadenceDisplay.setText("--");
        }

        // Show whether current cadence is inside configured zone
        var minZone = getApp().getMinCadence();
        var maxZone = getApp().getMaxCadence();
        var zoneText = "";
        if (info != null && info.currentCadence != null) {
            var c = info.currentCadence;
            if (c >= minZone && c <= maxZone) {
                zoneText = (WatchUi.loadResource(Rez.Strings.zone_in) as String) + " (" + minZone.toString() + "-" + maxZone.toString() + ")";
            } else {
                zoneText = (WatchUi.loadResource(Rez.Strings.zone_out) as String) + " (" + minZone.toString() + "-" + maxZone.toString() + ")";
            }
        } else {
            zoneText = "(" + minZone.toString() + "-" + maxZone.toString() + ")";
        }
        if (_cadenceZoneDisplay != null) {
            _cadenceZoneDisplay.setText(zoneText);
        }

        // Trigger haptic on zone crossing with timed alerts
        var newZoneState = 0;
        if (info != null && info.currentCadence != null) {
            var c = info.currentCadence;
            if (c < minZone) {
                newZoneState = -1;
            } else if (c > maxZone) {
                newZoneState = 1;
            } else {
                newZoneState = 0;
            }
        }

        if (newZoneState != _lastZoneState) {
            if (newZoneState == -1) {
                // Below minimum - start alert cycle
                _alertStartTime = System.getTimer();
                _lastAlertTime = System.getTimer();
                triggerSingleVibration();
            } else if (newZoneState == 1) {
                // Above maximum - start alert cycle
                _alertStartTime = System.getTimer();
                _lastAlertTime = System.getTimer();
                triggerDoubleVibration();
            } else {
                // Back in zone - stop alerts
                _alertStartTime = null;
                _lastAlertTime = 0;
            }
            _lastZoneState = newZoneState;
        } else {
            // Still out of zone - check if we need to alert again
            checkAndTriggerAlerts();
        }

        if (info != null && info.currentHeartRate != null){
            _heartrateDisplay.setText(info.currentHeartRate.toString());
        }else{
            _heartrateDisplay.setText("--");
        }

        // Display distance in kilometers with 2 decimal places
        if (info != null && info.elapsedDistance != null){
            var distanceKm = info.elapsedDistance / 100000.0; // Convert centimeters to kilometers
            _distanceDisplay.setText(distanceKm.format("%.2f") + " km");
        }else{
            _distanceDisplay.setText("-- km");
        }

        // Display elapsed time in HH:MM:SS format
        if (info != null && info.timerTime != null){
            var seconds = info.timerTime / 1000; // Convert milliseconds to seconds
            var hours = seconds / 3600;
            var minutes = (seconds % 3600) / 60;
            var secs = seconds % 60;
            _timeDisplay.setText(hours.format("%02d") + ":" + minutes.format("%02d") + ":" + secs.format("%02d"));
        }else{
            _timeDisplay.setText("--:--:--");
        }

        /// --- Cadence Quality (Easter Egg) ---
        if (_cqDisplay != null) {
            var app = getApp();
            var frozenCQ = app.getFinalCadenceQuality();

            if (frozenCQ != null) {
                _cqDisplay.setText("CQ: " + frozenCQ.format("%d") + "%");
            } else {
                var cq = app.computeCadenceQualityScore();

                if (cq < 0) {
                    _cqDisplay.setText("CQ: --");
                } else {
                    _cqDisplay.setText("CQ: " + cq.format("%d") + "%");
                }
            }
        }

        
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        _cadenceDisplay = findDrawableById("cadence_text");
        _cadenceZoneDisplay = findDrawableById("cadence_zone");
        _heartrateDisplay = findDrawableById("heartrate_text");
        _distanceDisplay = findDrawableById("distance_text");
        _timeDisplay = findDrawableById("time_text");
        _cqDisplay = findDrawableById("cq_text");
        _hardcoreDisplay = findDrawableById("hardcore_text");
    }

}

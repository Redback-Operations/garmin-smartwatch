import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;
import Toybox.Attention;

class AdvancedView extends WatchUi.View {
    const MAX_BARS = 280;
    const MAX_CADENCE_DISPLAY = 200;

    private var _simulationTimer;
    
    // Vibration alert tracking (no extra timers needed!)
    private var _lastZoneState = 0; // -1 = below, 0 = inside, 1 = above
    private var _alertStartTime = null;
    private var _alertDuration = 180000; // 3 minutes in milliseconds
    private var _alertInterval = 30000; // 30 seconds in milliseconds
    private var _lastAlertTime = 0;
    private var _pendingSecondVibe = false;
    private var _secondVibeTime = 0;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        _simulationTimer = new Timer.Timer();
        _simulationTimer.start(method(:refreshScreen), 1000, true);
    }

    function onHide() as Void {
        if (_simulationTimer != null) {
            _simulationTimer.stop();
            _simulationTimer = null;
        }
        // Reset alert state
        _alertStartTime = null;
        _lastAlertTime = 0;
    }

    function onUpdate(dc as Dc) as Void {
        // Check cadence zone for vibration alerts
        checkCadenceZone();
        
        // Check for pending second vibration
        checkPendingVibration();
        
        View.onUpdate(dc);
        // Draw all the elements
        drawElements(dc);
    }

    function refreshScreen() as Void {
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
    
    function checkCadenceZone() as Void {
        var info = Activity.getActivityInfo();
        var app = getApp();
        var minZone = app.getMinCadence();
        var maxZone = app.getMaxCadence();
        
        // Determine zone state
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

        // Trigger alerts on zone crossing
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
    }

    function drawElements(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var info = Activity.getActivityInfo();
        var app = getApp();
        
        // Draw elapsed time at top (yellow RGB: 255,248,18 = 0xFFF, using picker in paint to get RGB then convert to hex
        if (info != null && info.timerTime != null) {
            var seconds = info.timerTime / 1000;
            var hours = seconds / 3600;
            var minutes = (seconds % 3600) / 60;
            //var secs = seconds % 60;
            var timeStr = hours.format("%01d") + ":" + minutes.format("%02d"); //+ "." + secs.format("%02d");
            dc.setColor(0xFFF813, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, 3, Graphics.FONT_LARGE, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw heart rate circle (left, dark red RGB: 211,19,2519
        var hrX = width / 4;
        var hrY = (height * 2) / 7;
        var circleRadius = 42;
        
        dc.setColor(0x9D0000, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(hrX, hrY, circleRadius);
        
        if (info != null && info.currentHeartRate != null) {
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT); // White RGB: 255,255,255
            dc.drawText(hrX, hrY - 25, Graphics.FONT_TINY, info.currentHeartRate.toString(), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(hrX, hrY + 8, Graphics.FONT_XTINY, "bpm", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw distance circle (right, dark green RGB: 24,19,24 = 0x1D5E11)
        var distX = (width * 3) / 4;
        var distY = hrY;
        
        dc.setColor(0x1D5E11, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(distX, distY, circleRadius);
        
        if (info != null && info.elapsedDistance != null) {
            var distanceKm = info.elapsedDistance / 100000.0;
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT); // White RGB: 255,255,255
            dc.drawText(distX, distY - 25, Graphics.FONT_TINY, distanceKm.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(distX, distY + 8, Graphics.FONT_XTINY, "km", Graphics.TEXT_JUSTIFY_CENTER);
        }

        //draw ideal cadence range
        
        var idealMinCadence = app.getMinCadence();
        var idealMaxCadence = app.getMaxCadence();

        var cadenceY = height * 0.37;
        var cadenceRangeY = height * 0.43;
        var chartDurationY = height * 0.85;

        if (info != null && info.currentCadence != null) {
            // Draw cadence value in green (RGB: 0,255,0 = 0x00FF00)
            correctColor(info.currentCadence, idealMinCadence, idealMaxCadence, dc);
            dc.drawText(width / 2, cadenceY, Graphics.FONT_XTINY, info.currentCadence.toString() + " spm", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Display cadence zone range
        var minZone = app.getMinCadence();
        var maxZone = app.getMaxCadence();
        var zoneText = "Target: " + minZone.toString() + "-" + maxZone.toString() + " spm";

        dc.setColor(0x969696, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, cadenceRangeY, Graphics.FONT_XTINY, zoneText, Graphics.TEXT_JUSTIFY_CENTER);

        drawChart(dc);

        var string  = app.getChartDuration();

        dc.setColor(0x969696, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, chartDurationY, Graphics.FONT_XTINY, "Last " + string, Graphics.TEXT_JUSTIFY_CENTER);
    }



    /**
    Functions to continous update the chart with live cadence data. 
    The chart is split into bars each representing a candence reading,
    Each bar data is retrieve from an cadencecadence array which is updated every tick
    Each update the watchUI redraws the chart with the latest data.
    }
    **/
    
    function drawChart(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        //margins value
        var margin = width * 0.1;
        var marginLeftRightMultiplier = 1.38;
        var marginBottomMultiplier = 1.6;

        //chart position
        var chartLeft = margin * marginLeftRightMultiplier;
        var chartRight = width - chartLeft;
        var chartTop = height * 0.5;
        var chartBottom = height - margin*marginBottomMultiplier;
        var chartWidth = chartRight - chartLeft;
        var chartHeight = chartBottom - chartTop;
        var quarterChartHeight = chartHeight / 4;

        //bar zone
        var barZoneLeft = chartLeft + 1;
        var barZoneRight = chartRight - 1;
        var barZoneWidth = barZoneRight - barZoneLeft;
        var barZoneBottom = chartBottom - 1;

        //additional line indicator
        var nLine = 3;
        var lineLength = 6;
        var line1x1 = chartLeft - lineLength;
        var line1x2 = chartLeft;
        var line2x1 = chartRight - 1;
        var line2x2 = chartRight + lineLength;
        var lineY = chartTop + quarterChartHeight;

        // Draw white border around chart
        dc.setColor(0x969696, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(chartLeft, chartTop, chartWidth, chartHeight);
        for(var i = 0; i < nLine; i++){
            dc.drawLine(line1x1,lineY,line1x2,lineY);
            dc.drawLine(line2x1,lineY,line2x2,lineY);
            lineY += quarterChartHeight;
        }
        
        // Get data from app
        var app = getApp();
        var idealMinCadence = app.getMinCadence();
        var idealMaxCadence = app.getMaxCadence();
        var cadenceHistory = app.getCadenceHistory();

        var cadenceIndex = app.getCadenceIndex();
        var cadenceCount = app.getCadenceCount();
        
        if(cadenceCount == 0) {return;}
       
        var numBars = cadenceCount;
        var barWidth = (barZoneWidth / MAX_BARS).toNumber();
        var startIndex = (cadenceIndex - numBars + MAX_BARS) % MAX_BARS;
        
        // FIXED SCALE - bars have fixed height based on absolute cadence
        // Colors change dynamically based on your zone
        for (var i = 0; i < numBars; i++) {
            var index = (startIndex + i) % MAX_BARS;
            var cadence = cadenceHistory[index];
            if(cadence == null) {cadence = 0;}
            
            // Fixed bar height - same cadence always same height
            var barHeight = ((cadence / MAX_CADENCE_DISPLAY) * chartHeight).toNumber();
            var x = barZoneLeft + i * barWidth;
            var y = barZoneBottom - barHeight;

            correctColor(cadence, idealMinCadence, idealMaxCadence, dc);
            
            dc.fillRectangle(x, y, barWidth, barHeight);
        }
    }


    function correctColor(cadence as Number, idealMinCadence as Number, idealMaxCadence as Number, dc as Dc) as Void{
        var colorThreshold = 20;
        
        if(cadence < idealMinCadence)
        {
            if(cadence  > idealMinCadence - colorThreshold){ 
                dc.setColor(0x0cc0df, Graphics.COLOR_TRANSPARENT); //blue
            }
            else{
                dc.setColor(0x969696, Graphics.COLOR_TRANSPARENT);//grey
            }
            
        }
        else if (cadence > idealMaxCadence)
        {
            if(cadence < idealMaxCadence + colorThreshold){
                dc.setColor(0xff751f, Graphics.COLOR_TRANSPARENT);//orange
            }
            else{
                dc.setColor(0xFF0000, Graphics.COLOR_TRANSPARENT);//red
            }
        }
        else
        {
            dc.setColor(0x00bf63, Graphics.COLOR_TRANSPARENT);//green
        }
    }
}

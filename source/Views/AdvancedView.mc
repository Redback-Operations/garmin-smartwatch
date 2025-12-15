import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;

class AdvancedView extends WatchUi.View {
    const MAX_BARS = 60;
    const BASELINE_AVG_CADENCE = 150;
    const MAX_CADENCE_DISPLAY = 200;
    const HEIGHT_BASELINE = 170;
    const STEP_RATE = 6;

    private var _simulationTimer;
    private var _updateCount = 0;

    function initialize() {
        View.initialize();
        Logger.log(Logger.INFO, "AdvancedView", "View initialized");
    }

    function onShow() as Void {
        try {
            Logger.log(Logger.INFO, "AdvancedView", "View shown");
            _simulationTimer = new Timer.Timer();
            _simulationTimer.start(method(:refreshScreen), 1000, true);
            _updateCount = 0;
        } catch (e) {
            Logger.logError("AdvancedView", "Error in onShow", e);
        }
    }

    function onHide() as Void {
        try {
            Logger.log(Logger.INFO, "AdvancedView", "View hidden (updates: " + _updateCount + ")");
            if (_simulationTimer != null) {
                _simulationTimer.stop();
                _simulationTimer = null;
            }
        } catch (e) {
            Logger.logError("AdvancedView", "Error in onHide", e);
        }
    }

    function onUpdate(dc as Dc) as Void {
        try {
            View.onUpdate(dc);
            drawElements(dc);
            _updateCount++;
            
            // Log memory periodically
            if (_updateCount % 30 == 0) {
                Logger.logMemoryStats("AdvancedView");
            }
        } catch (e) {
            Logger.logCrash("AdvancedView", "Critical error in onUpdate", e);
            // Try to show error message to user
            try {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
                dc.clear();
                dc.drawText(dc.getWidth()/2, dc.getHeight()/2, 
                    Graphics.FONT_SMALL, "Display Error", Graphics.TEXT_JUSTIFY_CENTER);
            } catch (ex) {
                // If even error display fails, just log it
                System.println("Failed to display error: " + ex.getErrorMessage());
            }
        }
    }

    function refreshScreen() as Void {
        try {
            WatchUi.requestUpdate();
        } catch (e) {
            Logger.logError("AdvancedView", "Error requesting update", e);
        }
    }



    function drawElements(dc as Dc) as Void {
        try {
            var width = dc.getWidth();
            var height = dc.getHeight();
            var info = Activity.getActivityInfo();
            var app = getApp();
            
            // Validate dimensions
            if (width <= 0 || height <= 0) {
                Logger.log(Logger.ERROR, "AdvancedView", "Invalid display dimensions: " + width + "x" + height);
                return;
            }
            
            // Draw elapsed time at top
            drawElapsedTime(dc, width, height, info);
            
            // Draw heart rate circle (left)
            drawHeartRate(dc, width, height, info);
            
            // Draw distance circle (right)
            drawDistance(dc, width, height, info);
            
            // Draw ideal cadence range
            drawIdealCadenceRange(dc, width, height, app);
            
            // Draw current cadence
            drawCurrentCadence(dc, width, height, info, app);
            
            // Draw chart
            drawChart(dc);
            
        } catch (e) {
            Logger.logCrash("AdvancedView", "Error in drawElements", e);
            throw e; // Re-throw to trigger onUpdate error handling
        }
    }

    function drawElapsedTime(dc as Dc, width as Number, height as Number, info) as Void {
        try {
            if (info != null && info.timerTime != null) {
                var seconds = info.timerTime / 1000;
                var hours = seconds / 3600;
                var minutes = (seconds % 3600) / 60;
                var secs = seconds % 60;
                var timeStr = hours.format("%01d") + ":" + minutes.format("%02d") + "." + secs.format("%02d");
                dc.setColor(0xFFF813, Graphics.COLOR_TRANSPARENT);
                dc.drawText(width / 2, 3, Graphics.FONT_LARGE, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
            }
        } catch (e) {
            Logger.logError("AdvancedView", "Error drawing elapsed time", e);
        }
    }

    function drawHeartRate(dc as Dc, width as Number, height as Number, info) as Void {
        try {
            var hrX = width / 4;
            var hrY = (height * 2) / 5;
            var circleRadius = 42;
            
            dc.setColor(0x9D0000, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(hrX, hrY, circleRadius);
            
            if (info != null && info.currentHeartRate != null) {
                dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
                dc.drawText(hrX, hrY - 25, Graphics.FONT_TINY, info.currentHeartRate.toString(), Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(hrX, hrY + 8, Graphics.FONT_XTINY, "bpm", Graphics.TEXT_JUSTIFY_CENTER);
            }
        } catch (e) {
            Logger.logError("AdvancedView", "Error drawing heart rate", e);
        }
    }

    function drawDistance(dc as Dc, width as Number, height as Number, info) as Void {
        try {
            var distX = (width * 3) / 4;
            var distY = (height * 2) / 5;
            var circleRadius = 42;
            
            dc.setColor(0x1D5E11, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(distX, distY, circleRadius);
            
            if (info != null && info.elapsedDistance != null) {
                var distanceKm = info.elapsedDistance / 100000.0;
                dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
                dc.drawText(distX, distY - 25, Graphics.FONT_TINY, distanceKm.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(distX, distY + 8, Graphics.FONT_XTINY, "km", Graphics.TEXT_JUSTIFY_CENTER);
            }
        } catch (e) {
            Logger.logError("AdvancedView", "Error drawing distance", e);
        }
    }

    function drawIdealCadenceRange(dc as Dc, width as Number, height as Number, app as GarminApp) as Void {
        try {
            var idealMinCadence = app.getMinCadence();
            var idealMaxCadence = app.getMaxCadence();
            var idealCadenceY = height * 0.45;
            
            if(idealMinCadence != null && idealMaxCadence != null){
                var displayString = (idealMinCadence + " - " + idealMaxCadence).toString();
                dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
                dc.drawText(width / 2, idealCadenceY, Graphics.FONT_XTINY, displayString, Graphics.TEXT_JUSTIFY_CENTER);
            }
        } catch (e) {
            Logger.logError("AdvancedView", "Error drawing ideal cadence range", e);
        }
    }

    function drawCurrentCadence(dc as Dc, width as Number, height as Number, info, app as GarminApp) as Void {
        try {
            var cadenceY = height * 0.8;
            var idealMinCadence = app.getMinCadence();
            var idealMaxCadence = app.getMaxCadence();

            if (info != null && info.currentCadence != null) {
                dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
                dc.drawText(width / 2, cadenceY, Graphics.FONT_XTINY, "CADENCE", Graphics.TEXT_JUSTIFY_CENTER);
                
                correctColor(info.currentCadence, idealMinCadence, idealMaxCadence, dc);
                dc.drawText(width / 2, cadenceY + 20, Graphics.FONT_XTINY, info.currentCadence.toString() + "  spm", Graphics.TEXT_JUSTIFY_CENTER);
            }
        } catch (e) {
            Logger.logError("AdvancedView", "Error drawing current cadence", e);
        }
    }

    /**
    Functions to continuously update the chart with live cadence data. 
    The chart is split into bars each representing a cadence reading,
    Each bar data is retrieved from a cadence array which is updated every tick
    Each update the watchUI redraws the chart with the latest data.
    **/
    function drawChart(dc as Dc) as Void {
        try {
            var width = dc.getWidth();
            var height = dc.getHeight();
            
            //margins value
            var margin = width * 0.1;
            var marginLeftRightMultiplier = 1.2;
            var marginTopMultiplier = 0.5;
            var marginBottomMultiplier = 2;

            //chart position
            var chartLeft = margin * marginLeftRightMultiplier;
            var chartRight = width - chartLeft;
            var chartTop = height * 0.5 + margin * marginTopMultiplier;
            var chartBottom = height - margin*marginBottomMultiplier;
            var chartWidth = chartRight - chartLeft;
            var chartHeight = chartBottom - chartTop;
            
            // Validate chart dimensions
            if (chartWidth <= 0 || chartHeight <= 0) {
                Logger.log(Logger.WARNING, "AdvancedView", "Invalid chart dimensions");
                return;
            }
            
            // Draw white border around chart
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
            dc.drawRectangle(chartLeft, chartTop, chartWidth, chartHeight);
            
            // Get data from app
            var app = getApp();
            var idealMinCadence = app.getMinCadence();
            var idealMaxCadence = app.getMaxCadence();
            var cadenceHistory = app.getCadenceHistory();
            var cadenceIndex = app.getCadenceIndex();
            var cadenceCount = app.getCadenceCount();
            
            //check array ?null
            if(cadenceCount == 0) {
                Logger.log(Logger.DEBUG, "AdvancedView", "No cadence data to display");
                return;
            }

            // Calculate bar width
            var numBars = cadenceCount;
            if(numBars == 0) { return; }
            var barWidth = chartWidth / MAX_BARS;

            var startIndex = (cadenceIndex - numBars + MAX_BARS) % MAX_BARS;
            
            // Draw bars
            for (var i = 0; i < numBars; i++) {
                try {
                    var index = (startIndex + i) % MAX_BARS;
                    var cadence = cadenceHistory[index];
                    if(cadence == null) {cadence = 0;}
                        
                    //calculate bar height and position
                    var barHeight = (cadence / MAX_CADENCE_DISPLAY) * chartHeight;
                    var x = chartLeft + i * barWidth;
                    var y = chartBottom - barHeight;

                    //separation between each bar
                    var barOffset = 1;
                    correctColor(cadence, idealMinCadence, idealMaxCadence, dc);
                    dc.fillRectangle(x, y, barWidth-barOffset, barHeight);
                } catch (e) {
                    // Log but continue drawing other bars
                    if (i == 0) { // Only log first error to avoid spam
                        Logger.logError("AdvancedView", "Error drawing bar " + i, e);
                    }
                }
            }
        } catch (e) {
            Logger.logError("AdvancedView", "Error in drawChart", e);
        }
    }
}

function correctColor(cadence as Number, idealMinCadence as Number, idealMaxCadence as Number, dc as Dc) as Void{
    try {
        if(cadence <= idealMinCadence)
        {
            dc.setColor(0x0000FF, Graphics.COLOR_TRANSPARENT);//blue
        } 
        else if (cadence >= idealMaxCadence)
        {
           dc.setColor(0xFF0000, Graphics.COLOR_TRANSPARENT);//red
        }
        else
        {
            dc.setColor(0x00FF00, Graphics.COLOR_TRANSPARENT);//green
        }
    } catch (e) {
        Logger.logError("AdvancedView", "Error setting color", e);
        // Default to white if color setting fails
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
    }
}

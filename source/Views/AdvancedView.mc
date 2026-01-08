import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;

class AdvancedView extends WatchUi.View {
    const MAX_BARS = 60;
    const MAX_CADENCE_DISPLAY = 200;

    private var _simulationTimer;

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
    }

    function onUpdate(dc as Dc) as Void {
       View.onUpdate(dc);
        // Draw all the elements
        drawElements(dc);
    }

    function refreshScreen() as Void {
        WatchUi.requestUpdate();
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
            var secs = seconds % 60;
            var timeStr = hours.format("%01d") + ":" + minutes.format("%02d") + "." + secs.format("%02d");
            dc.setColor(0xFFF813, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, 3, Graphics.FONT_LARGE, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Draw heart rate circle (left, dark red RGB: 211,19,2519
        var hrX = width / 4;
        var hrY = (height * 2) / 5;
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
        var idealCadenceY = height * 0.45;
        

        if(idealMinCadence != null && idealMaxCadence != null){
            var displayString = (idealMinCadence + " - " + idealMaxCadence).toString();
            dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2,idealCadenceY , Graphics.FONT_XTINY, displayString, Graphics.TEXT_JUSTIFY_CENTER);
        }

        var cadenceY = height * 0.8;

        if (info != null && info.currentCadence != null) {
            // Draw "CADENCE" label (light gray RGB: 170,170,170 = 0xAAAAAA)
            dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, cadenceY, Graphics.FONT_XTINY, "CADENCE", Graphics.TEXT_JUSTIFY_CENTER);
            
            // Draw cadence value in green (RGB: 0,255,0 = 0x00FF00)
            correctColor(info.currentCadence, idealMinCadence, idealMaxCadence, dc);
            dc.drawText(width / 2, cadenceY + 20, Graphics.FONT_XTINY, info.currentCadence.toString() + "  spm", Graphics.TEXT_JUSTIFY_CENTER);
        }

        drawChart(dc);
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
        
        // Draw white border around chart (RGB: 255,255,255 = 0xFFFFFF)
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
        if(cadenceCount == 0) {return;}

        // Calculate bar width
        var numBars = cadenceCount;
        if(numBars == 0) { return; }
        var barWidth = chartWidth / MAX_BARS;

        var startIndex = (cadenceIndex - numBars + MAX_BARS) % MAX_BARS;
        
        // Draw bars
        for (var i = 0; i < numBars; i++) {
            var index = (startIndex + i) % MAX_BARS; // Start from oldest data
            var cadence = cadenceHistory[index];
            if(cadence == null) {cadence = 0;}
                
            //calculate bar height and position
            var barHeight = (cadence / MAX_CADENCE_DISPLAY) * chartHeight;
            var x = chartLeft + i * barWidth;
            var y = chartBottom - barHeight;

            //seperation between each bar
            var barOffset = 1;
            correctColor(cadence, idealMinCadence, idealMaxCadence, dc);
            dc.fillRectangle(x, y, barWidth-barOffset, barHeight);
        }
    }
}

function correctColor(cadence as Number, idealMinCadence as Number, idealMaxCadence as Number, dc as Dc) as Void{
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
}

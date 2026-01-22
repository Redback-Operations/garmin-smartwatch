import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;

class AdvancedView extends WatchUi.View {
    const MAX_BARS = 280;
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
        var chartDurationY = height * 0.85;

        if (info != null && info.currentCadence != null) {
            // Draw cadence value in green (RGB: 0,255,0 = 0x00FF00)
            correctColor(info.currentCadence, idealMinCadence, idealMaxCadence, dc);
            dc.drawText(width / 2, cadenceY + 20, Graphics.FONT_XTINY, info.currentCadence.toString() + " spm", Graphics.TEXT_JUSTIFY_CENTER);
        }

        drawChart(dc);

        // Display cadence zone range instead of time duration
        var minZone = app.getMinCadence();
        var maxZone = app.getMaxCadence();
        var zoneText = "Zone: " + minZone.toString() + "-" + maxZone.toString() + " spm";

        dc.setColor(0x969696, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, chartDurationY, Graphics.FONT_XTINY, zoneText, Graphics.TEXT_JUSTIFY_CENTER);

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
        //var marginTopMultiplier = 0.5;
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


        // Draw white border around chart (RGB: 255,255,255 = 0xFFFFFF)
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
        
        //hardcoded natural running cadence test array
        /*
        var cadenceHistory = [
                // Long warm-up/easy pace phase (bars 0-220): staying relatively low around 62-100 with noise
                62, 65, 63, 68, 66, 70, 67, 72, 69, 74,
                71, 76, 73, 78, 75, 81, 77, 83, 79, 85,
                82, 87, 84, 89, 86, 91, 88, 94, 90, 96,
                93, 98, 95, 100, 97, 102, 99, 104, 101, 103,
                100, 98, 95, 97, 94, 96, 92, 94, 90, 92,
                88, 90, 86, 88, 84, 86, 82, 85, 80, 83,
                81, 84, 82, 86, 83, 88, 85, 90, 87, 92,
                89, 94, 91, 96, 93, 98, 95, 100, 97, 102,
                99, 104, 101, 106, 103, 105, 102, 100, 98, 96,
                94, 92, 90, 88, 86, 84, 82, 85, 83, 87,
                85, 89, 87, 91, 89, 93, 91, 95, 93, 97,
                95, 99, 97, 101, 99, 100, 98, 96, 94, 92,
                90, 88, 86, 84, 82, 80, 78, 81, 79, 83,
                81, 85, 83, 87, 85, 89, 87, 91, 89, 93,
                91, 95, 93, 97, 95, 99, 97, 101, 99, 103,
                101, 105, 103, 107, 105, 106, 104, 102, 100, 98,
                96, 94, 92, 90, 88, 86, 84, 87, 85, 89,
                87, 91, 89, 93, 91, 88, 86, 84, 82, 85,
                83, 87, 85, 89, 87, 91, 89, 93, 91, 95,
                93, 97, 95, 99, 97, 101, 99, 100, 98, 96,
                94, 92, 90, 88, 91, 89, 93, 91, 95, 93,
                97, 95, 99, 97, 101, 99, 103, 101, 105, 103,
                107,
                
                // Sprint phase (bars 221-250): rapid increase to peak ~178 with noise
                109, 113, 110, 118, 115, 123, 120, 128, 125, 133,
                130, 138, 135, 143, 140, 148, 138, 135, 143, 140, 148, 163, 160, 168, 165, 173, 170, 178, 175, 176,
                115, 108, 110, 103, 105, 98, 93, 91, 95, 93, 154, 151,
                
                // Cool-down phase (bars 251-280): decrease back to ~62 with noise
                148, 143, 145, 138, 140, 133, 135, 128, 130, 123,
                125, 118, 120, 113, 115, 108, 110, 103, 105, 98,
                100, 118, 120, 113, 115, 108, 110, 78, 80, 73,
                75, 68, 70, 65, 67, 62, 64, 60, 62, 63
            ];*/

        var cadenceIndex = app.getCadenceIndex();
        var cadenceCount = app.getCadenceCount();
        //check array ?null
        if(cadenceCount == 0) {return;}
       
        var numBars = cadenceCount;
        var barWidth = (barZoneWidth / MAX_BARS).toNumber();

        var startIndex = (cadenceIndex - numBars + MAX_BARS) % MAX_BARS;
            
        // Draw bars
        for (var i = 0; i < numBars; i++) {
            var index = (startIndex + i) % MAX_BARS; // Start from oldest data
            var cadence = cadenceHistory[index];
            if(cadence == null) {cadence = 0;}
                    
            //calculate bar height and position
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

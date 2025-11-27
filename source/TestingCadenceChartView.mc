import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;

class TestingCadenceChartView extends WatchUi.View {

    private var _refreshTimer;

    function initialize() {
        View.initialize();
        _refreshTimer = new Timer.Timer();
        _refreshTimer.start(method(:refreshScreen), 3000, true);
    }

    function onLayout(dc as Dc) as Void {
        // No layout file needed - we'll draw directly
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Draw the chart
        drawChart(dc);
        
        // Draw title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 10, Graphics.FONT_SMALL, "Cadence Zone History", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {
        if (_refreshTimer != null) {
            _refreshTimer.stop();
        }
    }

    function refreshScreen() as Void {
        WatchUi.requestUpdate();
    }

    function drawChart(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Get zone history from app
        var app = getApp();
        var zoneHistory = app.getZoneHistory();
        var historyIndex = app.getHistoryIndex();
        
        // Chart area dimensions
        var chartTop = 40;
        var chartBottom = height - 20;
        var chartHeight = chartBottom - chartTop;
        var chartLeft = 5;
        var chartRight = width - 5;
        var chartWidth = chartRight - chartLeft;
        
        // Calculate bar width
        var numBars = 60;
        var barWidth = chartWidth / numBars;
        
        // Draw bars
        for (var i = 0; i < numBars; i++) {
            var dataIndex = (historyIndex + i) % 60; // Start from oldest data
            var zoneState = zoneHistory[dataIndex];
            
            if (zoneState != null) {
                var barX = chartLeft + (i * barWidth);
                var barY = chartTop;
                var barH = chartHeight;
                
                // Set color based on zone state
                if (zoneState == 0) {
                    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                } else if (zoneState == -1) {
                    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                }
                
                // Draw the bar
                dc.fillRectangle(barX, barY, barWidth - 1, barH);
            }
        }
        
        // Draw legend at the bottom
        var legendY = height - 15;
        var legendX = 10;
        
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(legendX, legendY, 8, 8);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(legendX + 12, legendY - 5, Graphics.FONT_XTINY, "Below", Graphics.TEXT_JUSTIFY_LEFT);
        
        legendX += 55;
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(legendX, legendY, 8, 8);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(legendX + 12, legendY - 5, Graphics.FONT_XTINY, "In Zone", Graphics.TEXT_JUSTIFY_LEFT);
        
        legendX += 55;
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(legendX, legendY, 8, 8);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(legendX + 12, legendY - 5, Graphics.FONT_XTINY, "Above", Graphics.TEXT_JUSTIFY_LEFT);
    }
}

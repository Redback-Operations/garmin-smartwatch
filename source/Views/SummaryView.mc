import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Toybox.Activity;

class SummaryView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var app = getApp();
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Check if we have valid summary data
        if (!app.hasValidSummaryData()) {
            drawNoDataMessage(dc, width, height);
            return;
        }

        // Draw summary content
        drawSummaryContent(dc, width, height, app);
    }

    function drawNoDataMessage(dc as Dc, width as Number, height as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_MEDIUM,
            "No data available",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawSummaryContent(dc as Dc, width as Number, height as Number, app as GarminApp) as Void {
        var yPos = 10;
        var lineHeight = 25;
        var sectionSpacing = 15;

        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            yPos,
            Graphics.FONT_SMALL,
            "SESSION SUMMARY",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        yPos += lineHeight + sectionSpacing;

        // Draw separator line
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, yPos, width - 10, yPos);
        yPos += sectionSpacing;

        // Cadence Quality Score (Large and prominent)
        var cq = app.getFinalCadenceQuality();
        if (cq != null) {
            var cqColor = getCQColor(cq);
            dc.setColor(cqColor, Graphics.COLOR_TRANSPARENT);
            
            // CQ Label
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                yPos,
                Graphics.FONT_SMALL,
                "Cadence Quality",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            yPos += lineHeight;

            // CQ Score (large)
            dc.setColor(cqColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width / 2,
                yPos,
                Graphics.FONT_NUMBER_HOT,
                cq.format("%d") + "%",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            yPos += lineHeight + 5;

            // CQ Confidence and Trend
            var confidence = app.getFinalCQConfidence();
            var trend = app.getFinalCQTrend();
            if (confidence != null && trend != null) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                var statusText = "(" + confidence + ", " + trend + ")";
                dc.drawText(
                    width / 2,
                    yPos,
                    Graphics.FONT_TINY,
                    statusText,
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                yPos += lineHeight + sectionSpacing;
            }
        }

        // Draw separator line
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, yPos, width - 10, yPos);
        yPos += sectionSpacing;

        // Time in Zone
        var timeInZone = app.getTimeInZonePercentage();
        if (timeInZone >= 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_SMALL,
                "Time in Zone:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_SMALL,
                timeInZone.format("%d") + "%",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight + 3;

            // Draw progress bar
            drawProgressBar(dc, width, yPos, timeInZone, Graphics.COLOR_GREEN);
            yPos += 12 + sectionSpacing;
        }

        // Average Cadence
        var avgCadence = app.getAverageCadence();
        if (avgCadence > 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_SMALL,
                "Avg Cadence:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_SMALL,
                avgCadence.format("%.0f") + " spm",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight + sectionSpacing;
        }

        // Min/Max Cadence
        var minCad = app.getMinCadenceFromHistory();
        var maxCad = app.getMaxCadenceFromHistory();
        if (minCad > 0 && maxCad > 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_TINY,
                "Range:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            var rangeText = minCad.format("%.0f") + "-" + maxCad.format("%.0f") + " spm";
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_TINY,
                rangeText,
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight;
        }

        // Target Zone
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            15,
            yPos,
            Graphics.FONT_TINY,
            "Target:",
            Graphics.TEXT_JUSTIFY_LEFT
        );
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var targetText = app.getMinCadence().toString() + "-" + app.getMaxCadence().toString() + " spm";
        dc.drawText(
            width - 15,
            yPos,
            Graphics.FONT_TINY,
            targetText,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
        yPos += lineHeight + sectionSpacing;

        // Draw separator line
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, yPos, width - 10, yPos);
        yPos += sectionSpacing;

        // Activity Metrics Section
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            yPos,
            Graphics.FONT_SMALL,
            "Activity Metrics",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        yPos += lineHeight + sectionSpacing;

        // Duration
        var duration = app.getSessionDuration();
        if (duration != null) {
            var seconds = duration / 1000;
            var hours = seconds / 3600;
            var minutes = (seconds % 3600) / 60;
            var secs = seconds % 60;
            var durationText = hours.format("%02d") + ":" + minutes.format("%02d") + ":" + secs.format("%02d");
            
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_SMALL,
                "Duration:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_SMALL,
                durationText,
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight + sectionSpacing;
        }

        // Distance
        var distance = app.getSessionDistance();
        if (distance != null) {
            var distanceKm = distance / 100000.0;
            
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_SMALL,
                "Distance:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_SMALL,
                distanceKm.format("%.2f") + " km",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight + sectionSpacing;
        }

        // Average Heart Rate
        var avgHR = app.getAvgHeartRate();
        if (avgHR != null) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_SMALL,
                "Avg HR:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_SMALL,
                avgHR.toString() + " bpm",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight;
        }

        // Peak Heart Rate (if different from average)
        var peakHR = app.getPeakHeartRate();
        if (peakHR != null && avgHR != null && peakHR > avgHR) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                15,
                yPos,
                Graphics.FONT_TINY,
                "Peak HR:",
                Graphics.TEXT_JUSTIFY_LEFT
            );
            
            dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                width - 15,
                yPos,
                Graphics.FONT_TINY,
                peakHR.toString() + " bpm",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
            yPos += lineHeight;
        }

        // Instructions at bottom
        yPos = height - 20;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            yPos,
            Graphics.FONT_XTINY,
            "Press SELECT to continue",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawProgressBar(dc as Dc, width as Number, yPos as Number, percentage as Number, color as Number) as Void {
        var barWidth = width - 30; // 15px margin on each side
        var barHeight = 8;
        var barX = 15;
        var barY = yPos;

        // Draw background (empty bar)
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barX, barY, barWidth, barHeight);

        // Draw filled portion
        if (percentage > 0) {
            var filledWidth = (barWidth * percentage / 100.0).toNumber();
            if (filledWidth > barWidth) { filledWidth = barWidth; }
            
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(barX, barY, filledWidth, barHeight);
        }

        // Draw border
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(barX, barY, barWidth, barHeight);
    }

    function getCQColor(cq as Number) as Number {
        if (cq >= 80) {
            return Graphics.COLOR_GREEN;
        } else if (cq >= 60) {
            return Graphics.COLOR_YELLOW;
        } else if (cq >= 40) {
            return Graphics.COLOR_ORANGE;
        } else {
            return Graphics.COLOR_RED;
        }
    }
}

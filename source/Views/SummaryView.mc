import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Activity;
import Toybox.WatchUi;

class SummaryView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

function onUpdate(dc as Dc) as Void {

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();

    var app = getApp();
    var width = dc.getWidth();
    var height = dc.getHeight();

    // Only show summary if valid data exists
    if (!app.hasValidSummaryData()) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            height / 2,
            Graphics.FONT_MEDIUM,
            "No data available",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        return;
    }

    var centerX = width / 2;
    var titleY = (height * 0.08).toNumber();
    var gap = (height * 0.14).toNumber();
    var startY = (height * 0.10).toNumber(); 

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

    // TITLE (tiny)
    dc.drawText(centerX, titleY, Graphics.FONT_XTINY,
        "Workout Summary",
        Graphics.TEXT_JUSTIFY_CENTER
    );

    //add for other metrics such as steps
    var duration = app.getSessionDuration();
    var distance = app.getSessionDistance();
    var hr = app.getAvgHeartRate();

    if (duration == null) { duration = 0; }
    if (distance == null) { distance = 0; }
    if (hr == null) { hr = 0; }

    // TIME FORMAT
    var seconds = duration / 1000;
    var h = seconds / 3600;
    var m = (seconds % 3600) / 60;
    var s = seconds % 60;

    var timeStr = h.format("%02d") + ":" +
                  m.format("%02d") + ":" +
                  s.format("%02d");

    // ===== METRICS =====
    var km = distance / 100000.0;

    var paceStr = "--";
    if (km > 0.0 && seconds > 0) {
        var paceSeconds = (seconds / km).toNumber();
        var paceMin = paceSeconds / 60;
        var paceSec = paceSeconds % 60;
        paceStr = paceMin.format("%d") + ":" + paceSec.format("%02d") + "/km";
    }

    // Get average cadence
    var avgCadence = app.getAverageCadence();
    var cadenceStr = avgCadence > 0 ? avgCadence.format("%.0f") + " SPM" : "--";

    // Get CQ score
    var cqStr = app.getfinalQC();

    drawRow(dc, width, startY + gap,     timeStr,                   :time,     "TIME");
    drawRow(dc, width, startY + gap * 2, paceStr,                   :pace,     "PACE");
    drawRow(dc, width, startY + gap * 3, cadenceStr,                :cadence,  "CADENCE");
    drawRow(dc, width, startY + gap * 4, cqStr,                     :quality,  "QUALITY");
    drawRow(dc, width, startY + gap * 5, km.format("%.2f") + " km", :distance, "DISTANCE");

}

function drawRow(dc as Dc, width as Number, y as Number, value as String, iconType as Symbol, label as String) as Void {
    var leftMargin = 10;
    var rightMargin = width - 15;
    var iconX = leftMargin + 15;
    var iconY = y;

    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    if (iconType == :time) {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(iconX, iconY, 12);
        dc.drawLine(iconX, iconY, iconX, iconY - 8);
        dc.drawLine(iconX, iconY, iconX + 6, iconY);
    } else if (iconType == :pace) {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        var pts = [[iconX+4, iconY-11], [iconX-3, iconY], [iconX+2, iconY], [iconX-4, iconY+11], [iconX+5, iconY-1], [iconX, iconY-1]];
        for (var i = 0; i < pts.size() - 1; i++) {
            dc.drawLine(pts[i][0], pts[i][1], pts[i+1][0], pts[i+1][1]);
        }
    } else if (iconType == :cadence) {
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(iconX - 9, iconY - 5,  4, 10);
        dc.fillRectangle(iconX - 2, iconY - 10, 4, 15);
        dc.fillRectangle(iconX + 5, iconY - 7,  4, 12);
    } else if (iconType == :quality) {
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(iconX, iconY - 3, 8, Graphics.ARC_CLOCKWISE, 0, 180);
        dc.drawLine(iconX - 8, iconY - 3, iconX - 8, iconY + 2);
        dc.drawLine(iconX + 8, iconY - 3, iconX + 8, iconY + 2);
        dc.drawLine(iconX - 5, iconY + 5, iconX + 5, iconY + 5);
        dc.drawLine(iconX, iconY + 5, iconX, iconY + 9);
        dc.drawLine(iconX - 5, iconY + 9, iconX + 5, iconY + 9);
    } else if (iconType == :distance) {
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(iconX - 10, iconY, iconX + 10, iconY);
        dc.drawLine(iconX + 5, iconY - 5, iconX + 10, iconY);
        dc.drawLine(iconX + 5, iconY + 5, iconX + 10, iconY);
    }
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    dc.drawText(leftMargin + 35, y, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    dc.drawText(rightMargin, y, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
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
               Graphics.FONT_XTINY,
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
       var targetText = app.getCalculatedMinCadence().toString() +"-" +app.getCalculatedMaxCadence().toString() +" spm";
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

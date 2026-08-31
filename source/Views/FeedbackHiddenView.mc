import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Post-run summary for Feedback On/Hidden mode.
// Shows how well the runner held target cadence DURING the periods
// where feedback was hidden. Green = held, Amber = reverted.
//
// This view renders from the variables below. They currently hold
// SAMPLE DATA so the screen can be built and tested in the simulator.
// Dev replaces these with real recorded values later (see hookup notes
// at the bottom) without changing any drawing code.
class FeedbackHiddenView extends WatchUi.View {

    // ===== DATA (Dev replaces sample values with real data) =====

    // % of hidden-period time the runner stayed in target range (0-100)
    private var _percentInRange as Number = 84;

    // Target cadence range, in spm
    private var _targetMin as Number = 140;
    private var _targetMax as Number = 160;

    // Cadence samples over the run (spm). Sample data for the graph.
    private var _cadenceData as Array<Number> = [148, 150, 149, 152, 150, 151, 149, 150, 152, 151];

    // Which sample-index ranges were feedback-hidden, as [start, end] pairs.
    private var _hiddenRanges as Array< Array<Number> > = [[2, 3], [7, 8]];

    // Threshold at/above which the runner is considered to have "held" (green)
    private const HELD_THRESHOLD = 70;

    function initialize() {
        View.initialize();
    }

    // Allow Dev to inject real data instead of the sample values.
    function setData(
        percentInRange as Number,
        targetMin as Number,
        targetMax as Number,
        cadenceData as Array<Number>,
        hiddenRanges as Array< Array<Number> >
    ) as Void {
        _percentInRange = percentInRange;
        _targetMin = targetMin;
        _targetMax = targetMax;
        _cadenceData = cadenceData;
        _hiddenRanges = hiddenRanges;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        // Colour state: green if held, amber if reverted
        var stateColor = getStateColor(_percentInRange);

        // ===== HEADING: "When hidden" =====
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.14).toNumber(),
            Graphics.FONT_XTINY,
            "When hidden",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // ===== BIG PERCENTAGE =====
        dc.setColor(stateColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.30).toNumber(),
            Graphics.FONT_NUMBER_HOT,
            _percentInRange.format("%d") + "%",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // ===== SUB-LABEL: "in target range" =====
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.44).toNumber(),
            Graphics.FONT_XTINY,
            "in target range",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // ===== MINI GRAPH =====
        var graphX = (width * 0.18).toNumber();
        var graphY = (height * 0.56).toNumber();
        var graphW = (width * 0.64).toNumber();
        var graphH = (height * 0.22).toNumber();
        drawMiniGraph(dc, graphX, graphY, graphW, graphH, stateColor);

        // ===== CAPTION =====
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.85).toNumber(),
            Graphics.FONT_XTINY,
            "Shaded = feedback hidden",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    // Draws the cadence trace: target band, hidden-window strips, and the line.
    function drawMiniGraph(dc as Dc, x as Number, y as Number, w as Number, h as Number, lineColor as Number) as Void {
        var count = _cadenceData.size();
        if (count < 2) { return; }

        var axisMin = _targetMin - 15;
        var axisMax = _targetMax + 15;
        var axisSpan = axisMax - axisMin;
        if (axisSpan <= 0) { axisSpan = 1; }

        // Background outline
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, w, h);

        // --- Target band (dark green filled strip) ---
        var bandTopY    = y + h - (((_targetMax - axisMin) * h) / axisSpan);
        var bandBottomY = y + h - (((_targetMin - axisMin) * h) / axisSpan);
        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, bandTopY, w, bandBottomY - bandTopY);

        // --- Hidden-window strips (faint outlines) ---
        var stepX = w / (count - 1);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        for (var r = 0; r < _hiddenRanges.size(); r++) {
            var startIdx = _hiddenRanges[r][0];
            var endIdx   = _hiddenRanges[r][1];
            var stripX = x + (startIdx * stepX);
            var stripW = (endIdx - startIdx) * stepX;
            dc.drawRectangle(stripX, y, stripW, h);
        }

        // --- Cadence line ---
        dc.setColor(lineColor, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < count - 1; i++) {
            var x1 = x + (i * stepX);
            var x2 = x + ((i + 1) * stepX);
            var y1 = y + h - (((_cadenceData[i] - axisMin) * h) / axisSpan);
            var y2 = y + h - (((_cadenceData[i + 1] - axisMin) * h) / axisSpan);
            if (y1 < y) { y1 = y; }
            if (y1 > y + h) { y1 = y + h; }
            if (y2 < y) { y2 = y; }
            if (y2 > y + h) { y2 = y + h; }
            dc.drawLine(x1, y1, x2, y2);
        }
    }

    // Green if the runner held target during hidden periods, amber if not.
    function getStateColor(percent as Number) as Number {
        if (percent >= HELD_THRESHOLD) {
            return Graphics.COLOR_GREEN;
        } else {
            return Graphics.COLOR_ORANGE;
        }
    }
}
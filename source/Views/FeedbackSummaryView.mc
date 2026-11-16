import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class FeedbackSummaryView extends WatchUi.View {

    private var _heartRateIcon;
    private var _useSavedData;

    function initialize(useSavedData as Boolean) {
        View.initialize();
        _useSavedData = useSavedData;
        _heartRateIcon = null;
    }

    function onLayout(dc as Dc) as Void {
        _heartRateIcon = WatchUi.loadResource(
            dc.getWidth() < 300
                ? Rez.Drawables.FeedbackHeartRateIconCompact
                : Rez.Drawables.FeedbackHeartRateIcon
        );
    }

    function onUpdate(dc as Dc) as Void {
        var app = getApp();
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var smallScreen = width < 300;
        var titleY = smallScreen ? 0.08 : 0.09;
        var scoreY = smallScreen ? 0.18 : 0.205;
        var scoreFont = smallScreen
            ? Graphics.FONT_MEDIUM
            : Graphics.FONT_NUMBER_MILD;
        var subtitleY = smallScreen ? 0.28 : 0.305;
        var legendY = smallScreen ? 0.76 : 0.77;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var hasData = _useSavedData
            ? app.hasSavedFeedbackSummaryData()
            : app.hasFeedbackSummaryData();
        if (!hasData) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                height / 2,
                Graphics.FONT_SMALL,
                _useSavedData ? "No saved feedback" : "No hidden-period data",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            return;
        }

        var score = _useSavedData
            ? app.getSavedFeedbackHiddenPercentage()
            : app.getFeedbackHiddenPercentage();
        var heldCadence = _useSavedData
            ? app.didHoldSavedCadenceWhenHidden()
            : app.didHoldCadenceWhenHidden();
        var stateColor = heldCadence
            ? Graphics.COLOR_GREEN
            : Graphics.COLOR_ORANGE;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * titleY).toNumber(),
            smallScreen ? Graphics.FONT_XTINY : Graphics.FONT_SMALL,
            "When hidden",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(stateColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * scoreY).toNumber(),
            scoreFont,
            score.toString() + "%",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * subtitleY).toNumber(),
            smallScreen ? Graphics.FONT_XTINY : Graphics.FONT_SMALL,
            "in target range",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        drawMetrics(dc, app, width, height);
        drawCadenceGraph(dc, app, stateColor, width, height);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * legendY).toNumber(),
            Graphics.FONT_XTINY,
            "Shaded = Feedback hidden",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawMetrics(dc as Dc, app, width as Number, height as Number) as Void {
        var heartRate = _useSavedData
            ? app.getSavedFeedbackHeartRate()
            : app.getAvgHeartRate();
        var distance = _useSavedData
            ? app.getSavedFeedbackDistance()
            : app.getSessionDistance();
        var heartRateText = heartRate == null ? "-- bpm" : heartRate.toString() + " bpm";
        var distanceText = distance == null
            ? "-- KM"
            : (distance / 1000.0).format("%.2f") + " KM";
        var smallScreen = width < 300;
        var y = (height * (smallScreen ? 0.37 : 0.385)).toNumber();

        if (_heartRateIcon != null) {
            dc.drawBitmap(
                (width * (smallScreen ? 0.08 : 0.07)).toNumber(),
                y - (_heartRateIcon.getHeight() / 2),
                _heartRateIcon
            );
        }

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            (width * (smallScreen ? 0.40 : 0.30)).toNumber(),
            y,
            Graphics.FONT_XTINY,
            heartRateText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            (width * (smallScreen ? 0.73 : 0.75)).toNumber(),
            y,
            Graphics.FONT_XTINY,
            distanceText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawCadenceGraph(
        dc as Dc,
        app as GarminApp,
        stateColor as Number,
        width as Number,
        height as Number
    ) as Void {
        var cadenceLog = _useSavedData
            ? app.getSavedFeedbackCadenceLog()
            : app.getFeedbackCadenceLog();
        var hiddenLog = _useSavedData
            ? app.getSavedFeedbackHiddenLog()
            : app.getFeedbackHiddenLog();
        var timeLog = _useSavedData
            ? app.getSavedFeedbackTimeLog()
            : app.getFeedbackTimeLog();
        var count = cadenceLog.size();

        if (count == 0) {
            return;
        }

        var smallScreen = width < 300;
        var cardLeft = (width * (smallScreen ? 0.10 : 0.09)).toNumber();
        var cardRight = (width * (smallScreen ? 0.90 : 0.91)).toNumber();
        var cardTop = (height * (smallScreen ? 0.45 : 0.47)).toNumber();
        var cardBottom = (height * (smallScreen ? 0.68 : 0.69)).toNumber();
        var cardWidth = cardRight - cardLeft;
        var cardHeight = cardBottom - cardTop;
        var left = cardLeft + (width * 0.09).toNumber();
        var right = cardRight - (width * 0.03).toNumber();
        var top = cardTop + (height * 0.035).toNumber();
        var bottom = cardBottom - (height * 0.055).toNumber();
        var graphWidth = right - left;
        var targetMin = _useSavedData
            ? app.getSavedFeedbackTargetMin()
            : app.getCalculatedMinCadence();
        var targetMax = _useSavedData
            ? app.getSavedFeedbackTargetMax()
            : app.getCalculatedMaxCadence();
        var graphMin = targetMin - 10;
        var graphMax = targetMax + 10;

        for (var i = 0; i < count; i++) {
            var cadence = cadenceLog[i];
            if (cadence != null) {
                if (cadence < graphMin) { graphMin = cadence; }
                if (cadence > graphMax) { graphMax = cadence; }
            }
        }

        if (graphMax <= graphMin) {
            graphMax = graphMin + 1;
        }

        // A rounded dark card matches the design while keeping the plotting
        // area comfortably inside the circular bezel.
        dc.setColor(0x111111, 0x111111);
        dc.fillRoundedRectangle(
            cardLeft,
            cardTop,
            cardWidth,
            cardHeight,
            (width * 0.055).toNumber()
        );

        var firstSecond = timeLog[0];
        var lastSecond = timeLog[count - 1];
        var timeSpan = lastSecond - firstSecond;
        if (timeSpan < 1) { timeSpan = 1; }

        // Hidden-period strips sit behind both the target range and cadence
        // line, making every layer readable at a glance.
        dc.setColor(0x202020, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < count; i++) {
            if (hiddenLog[i]) {
                var shadedX = left +
                    (((timeLog[i] - firstSecond) * graphWidth) / timeSpan).toNumber();
                var shadedEnd = right;
                if (i + 1 < count) {
                    shadedEnd = left +
                        (((timeLog[i + 1] - firstSecond) * graphWidth) / timeSpan).toNumber();
                }
                var shadedWidth = shadedEnd - shadedX + 1;
                if (shadedWidth < 2) { shadedWidth = 2; }
                if (shadedX + shadedWidth > right) {
                    shadedWidth = right - shadedX;
                }
                dc.fillRectangle(shadedX, cardTop, shadedWidth, cardHeight);
            }
        }

        var bandTop = cadenceToY(targetMax, graphMin, graphMax, top, bottom);
        var bandBottom = cadenceToY(targetMin, graphMin, graphMax, top, bottom);
        dc.setColor(0x174A2A, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left, bandTop, graphWidth, bandBottom - bandTop + 1);

        dc.setColor(stateColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(smallScreen ? 2 : 3);
        var previousX = -1;
        var previousY = -1;

        for (var i = 0; i < count; i++) {
            var cadence = cadenceLog[i];
            if (cadence == null) {
                previousX = -1;
                previousY = -1;
                continue;
            }

            var x = left +
                (((timeLog[i] - firstSecond) * graphWidth) / timeSpan).toNumber();
            var y = cadenceToY(cadence, graphMin, graphMax, top, bottom);

            if (previousX >= 0 && previousY >= 0) {
                dc.drawLine(previousX, previousY, x, y);
            }

            previousX = x;
            previousY = y;
        }
        dc.setPenWidth(1);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            left - 4,
            top,
            Graphics.FONT_XTINY,
            graphMax.toString(),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            left - 4,
            bottom,
            Graphics.FONT_XTINY,
            graphMin.toString(),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var firstMinute = 0.0;
        var lastMinute = timeSpan / 60.0;
        var middleMinute = lastMinute / 2.0;
        dc.drawText(
            left,
            cardBottom - (height * 0.05).toNumber(),
            Graphics.FONT_XTINY,
            firstMinute.format("%.0f"),
            Graphics.TEXT_JUSTIFY_LEFT
        );
        dc.drawText(
            (left + right) / 2,
            cardBottom - (height * 0.05).toNumber(),
            Graphics.FONT_XTINY,
            middleMinute.format("%.1f"),
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            right,
            cardBottom - (height * 0.05).toNumber(),
            Graphics.FONT_XTINY,
            lastMinute.format("%.1f"),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    function cadenceToY(
        cadence,
        graphMin as Number,
        graphMax as Number,
        top as Number,
        bottom as Number
    ) as Number {
        var ratio = (cadence - graphMin).toFloat() / (graphMax - graphMin);
        return bottom - ((bottom - top) * ratio).toNumber();
    }
}

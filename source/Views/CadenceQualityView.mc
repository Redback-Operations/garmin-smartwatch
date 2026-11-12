import Toybox.Activity;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

class CadenceQualityView extends WatchUi.View {

    const RANGE_PADDING_SPM = 20;

    const COLOR_BELOW = Graphics.COLOR_ORANGE;
    const COLOR_IN_RANGE = Graphics.COLOR_BLUE;
    const COLOR_ABOVE = Graphics.COLOR_RED;

    private var _heartIcon;
    private var _refreshTimer = null;

    function initialize() {
        View.initialize();
        _heartIcon = null;
    }

    function onLayout(dc as Dc) as Void {
        _heartIcon = WatchUi.loadResource(
            dc.getWidth() < 300
                ? Rez.Drawables.FeedbackHeartRateIconCompact
                : Rez.Drawables.IconHeartRate
        );
    }

    function onShow() as Void {
        stopRefreshTimer();
        _refreshTimer = new Timer.Timer();
        _refreshTimer.start(method(:refreshScreen), 1000, true);
        WatchUi.requestUpdate();
    }

    function onHide() as Void {
        stopRefreshTimer();
    }

    function refreshScreen() as Void {
        var app = Application.getApp() as GarminApp;
        if (app.isFeedbackHidden() && !app.shouldShowFeedbackHiddenNotice()) {
            // CadenceQualityView is pushed from the main dashboard. Once the
            // four-second notice expires, pop it so the runner returns home.
            stopRefreshTimer();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            return;
        }
        WatchUi.requestUpdate();
    }

    function stopRefreshTimer() as Void {
        if (_refreshTimer != null) {
            _refreshTimer.stop();
            _refreshTimer = null;
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var app = Application.getApp() as GarminApp;
        if (app.isFeedbackHidden()) {
            if (app.shouldShowFeedbackHiddenNotice()) {
                drawFeedbackHidden(dc, app);
            }
            return;
        }

        drawCadenceDisplay(dc, app, Activity.getActivityInfo());
    }

    function drawCadenceDisplay(dc as Dc, app as GarminApp, info) as Void {
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();
        var centerX = screenW / 2;

        var targetMin = app.getCalculatedMinCadence();
        var targetMax = app.getCalculatedMaxCadence();
        var cadence = null;
        var heartRate = null;
        var elapsedDistance = null;

        if (info != null) {
            if (info.currentCadence != null) {
                cadence = info.currentCadence.toNumber();
            }
            heartRate = info.currentHeartRate;
            elapsedDistance = info.elapsedDistance;
        }

        var stateColor = Graphics.COLOR_LT_GRAY;
        var statusText = "waiting";
        if (cadence != null) {
            if (cadence < targetMin) {
                stateColor = COLOR_BELOW;
                statusText = "faster";
            } else if (cadence > targetMax) {
                stateColor = COLOR_ABOVE;
                statusText = "slower";
            } else {
                stateColor = COLOR_IN_RANGE;
                statusText = "in range";
            }
        }

        drawTargetScore(dc, app, centerX, screenH);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(
            (screenW * 0.28).toNumber(),
            (screenH * 0.165).toNumber(),
            (screenW * 0.72).toNumber(),
            (screenH * 0.165).toNumber()
        );

        dc.setColor(stateColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (screenH * 0.235).toNumber(),
            screenW < 300 ? Graphics.FONT_MEDIUM : Graphics.FONT_LARGE,
            cadence == null ? "--" : cadence.toString(),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (screenH * 0.365).toNumber(),
            Graphics.FONT_XTINY,
            "SPM",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(stateColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (screenH * 0.425).toNumber(),
            Graphics.FONT_XTINY,
            statusText,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        drawTargetRange(dc, screenW, screenH, cadence, targetMin, targetMax, stateColor);
        drawHeartRate(dc, screenW, screenH, heartRate);
        drawDistance(dc, screenW, screenH, elapsedDistance);
    }

    function drawTargetScore(dc as Dc, app as GarminApp, centerX as Number, screenH as Number) as Void {
        var score = app.computeLiveTimeInZonePercentage();
        var sampleCount = app.getCadenceCount();
        var scoreText = score < 0 ? "--%" : score.toString() + "%";
        var detailText = "start recording";

        if (score >= 0) {
            detailText = "on target - " + sampleCount.toString() + "s";
        } else if (app.isRecording()) {
            detailText = "waiting for cadence";
        } else if (app.isPaused()) {
            detailText = "activity paused";
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (screenH * 0.045).toNumber(),
            Graphics.FONT_XTINY,
            scoreText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            centerX,
            (screenH * 0.095).toNumber(),
            Graphics.FONT_XTINY,
            detailText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawTargetRange(
        dc as Dc,
        screenW as Number,
        screenH as Number,
        cadence,
        targetMin as Number,
        targetMax as Number,
        stateColor as Number
    ) as Void {
        var barY = (screenH * 0.545).toNumber();
        var barStart = (screenW * 0.17).toNumber();
        var barEnd = (screenW * 0.83).toNumber();
        var barWidth = barEnd - barStart;
        var scaleMin = targetMin - RANGE_PADDING_SPM;
        var scaleMax = targetMax + RANGE_PADDING_SPM;
        var scaleSpan = scaleMax - scaleMin;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawLine(barStart, barY, barEnd, barY);
        dc.setPenWidth(1);

        var targetStartX = barStart +
            (((targetMin - scaleMin) * barWidth) / scaleSpan).toNumber();
        var targetEndX = barStart +
            (((targetMax - scaleMin) * barWidth) / scaleSpan).toNumber();
        var targetWidth = targetEndX - targetStartX;
        if (targetWidth < 8) { targetWidth = 8; }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRoundedRectangle(
            targetStartX,
            barY - (screenH * 0.020).toNumber(),
            targetWidth,
            (screenH * 0.040).toNumber(),
            6
        );

        if (cadence != null) {
            var clampedCadence = cadence;
            if (clampedCadence < scaleMin) { clampedCadence = scaleMin; }
            if (clampedCadence > scaleMax) { clampedCadence = scaleMax; }
            var markerX = barStart +
                (((clampedCadence - scaleMin) * barWidth) / scaleSpan).toNumber();

            dc.setColor(stateColor, stateColor);
            dc.fillRectangle(
                markerX - 1,
                barY - (screenH * 0.047).toNumber(),
                3,
                (screenH * 0.094).toNumber()
            );
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            targetStartX,
            (screenH * 0.600).toNumber(),
            Graphics.FONT_XTINY,
            targetMin.toString(),
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText(
            targetEndX,
            (screenH * 0.600).toNumber(),
            Graphics.FONT_XTINY,
            targetMax.toString(),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawHeartRate(dc as Dc, screenW as Number, screenH as Number, heartRate) as Void {
        if (_heartIcon != null) {
            dc.drawBitmap(
                (screenW * 0.20).toNumber(),
                (screenH * 0.690).toNumber(),
                _heartIcon
            );
        }

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            (screenW * 0.38).toNumber(),
            (screenH * 0.705).toNumber(),
            Graphics.FONT_XTINY,
            heartRate == null ? "--" : heartRate.toString(),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawDistance(dc as Dc, screenW as Number, screenH as Number, elapsedDistance) as Void {
        var distanceText = "-- KM";
        if (elapsedDistance != null) {
            distanceText = (elapsedDistance / 1000.0).format("%.2f") + " KM";
        }

        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            (screenW * 0.72).toNumber(),
            (screenH * 0.705).toNumber(),
            Graphics.FONT_XTINY,
            distanceText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawFeedbackHidden(dc as Dc, app as GarminApp) as Void {
        FeedbackHiddenRenderer.draw(dc, app);
    }
}

import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;

class ResetSettingsView extends WatchUi.View {

    private var _screenState;
    private var _selectedButton;
    private var _resetIcon;

    // 0 = reset open screen
    // 1 = confirmation screen
    // 2 = success screen

    function initialize() {
        View.initialize();

        _screenState = 0;
        _selectedButton = 0; // 0 = YES, 1 = NO
        _resetIcon = WatchUi.loadResource(Rez.Drawables.ResetIcon);
    }

    function onUpdate(dc as Dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (_screenState == 0) {
            drawResetOpenScreen(dc);
        } else if (_screenState == 1) {
            drawConfirmScreen(dc);
        } else {
            drawSuccessScreen(dc);
        }
    }

    function openConfirmScreen() {
        _screenState = 1;
        _selectedButton = 0;
        WatchUi.requestUpdate();
    }

    function moveSelectionUp() {
        if (_screenState == 1) {
            _selectedButton = 0;
            WatchUi.requestUpdate();
        }
    }

    function moveSelectionDown() {
        if (_screenState == 1) {
            _selectedButton = 1;
            WatchUi.requestUpdate();
        }
    }

    function selectCurrentOption() {

        if (_screenState == 0) {
            openConfirmScreen();
            return;
        }

        if (_screenState == 1) {
            if (_selectedButton == 0) {
                resetAllSettings();
                _screenState = 2;
            } else {
                _screenState = 0;
            }

            WatchUi.requestUpdate();
            return;
        }

        if (_screenState == 2) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return;
        }
    }

    function handleBack() {
        if (_screenState == 2) {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        } else if (_screenState == 1) {
            _screenState = 0;
            WatchUi.requestUpdate();
        } else {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }

    function resetAllSettings() {
        var app = Application.getApp() as GarminApp;

        if (app != null) {
            app.resetAllSettings();
        }

        System.println("[RESET] All settings restored to default");
    }

    // ---------------------------------------------------------
    // SCREEN 1: Reset Settings open screen
    // ---------------------------------------------------------

    function drawResetOpenScreen(dc as Dc) {
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();

        var centerX = screenW / 2;

        // This keeps the whole group visually centered.
        var iconSize = _resetIcon.getWidth();
        var iconY = (screenH * 0.22).toNumber();

        dc.drawBitmap(centerX - (iconSize / 2), iconY, _resetIcon);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (screenH * 0.57).toNumber(),
            Graphics.FONT_MEDIUM,
            "Reset Settings",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (screenH * 0.72).toNumber(),
            Graphics.FONT_XTINY,
            "START to open",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    // ---------------------------------------------------------
    // SCREEN 2: Confirmation screen
    // ---------------------------------------------------------

    function drawConfirmScreen(dc as Dc) {
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();

        var centerX = screenW / 2;

        // Question block
        var questionTop = (screenH * 0.20).toNumber();
        var lineGap = (screenH * 0.11).toNumber();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            centerX,
            questionTop,
            Graphics.FONT_SMALL,
            "Are you sure",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            questionTop + lineGap,
            Graphics.FONT_SMALL,
            "you want to reset",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            questionTop + (lineGap * 2),
            Graphics.FONT_SMALL,
            "all settings?",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        drawButtons(dc, (screenH * 0.59).toNumber());
    }

    function drawButtons(dc as Dc, startY) {
        var centerX = dc.getWidth() / 2;

        var buttonW = (dc.getWidth() * 0.55).toNumber();
        var buttonH = (dc.getHeight() * 0.11).toNumber();
        var radius = 8;

        var buttonX = centerX - (buttonW / 2);

        var yesY = startY;
        var noY = startY + (dc.getHeight() * 0.15).toNumber();

        if (_selectedButton == 0) {
            drawButton(
                dc,
                buttonX,
                yesY,
                buttonW,
                buttonH,
                radius,
                Graphics.COLOR_RED,
                Graphics.COLOR_WHITE,
                "YES"
            );

            drawButton(
                dc,
                buttonX,
                noY,
                buttonW,
                buttonH,
                radius,
                0x4A4A4A,
                Graphics.COLOR_WHITE,
                "NO"
            );
        } else {
            drawButton(
                dc,
                buttonX,
                yesY,
                buttonW,
                buttonH,
                radius,
                0x4A4A4A,
                Graphics.COLOR_WHITE,
                "YES"
            );

            drawButton(
                dc,
                buttonX,
                noY,
                buttonW,
                buttonH,
                radius,
                Graphics.COLOR_GREEN,
                Graphics.COLOR_BLACK,
                "NO"
            );
        }
    }

    function drawButton(dc as Dc, x, y, w, h, r, fillColor, textColor, label) {
        dc.setColor(fillColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y, w, h, r);

        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);

        // Text is slightly adjusted to sit visually centered inside the button.
        dc.drawText(
            x + (w / 2),
            y + (h / 2),
            Graphics.FONT_XTINY,
            label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    // ---------------------------------------------------------
    // SCREEN 3: Success screen
    // ---------------------------------------------------------

    function drawSuccessScreen(dc as Dc) {
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();

        var centerX = screenW / 2;

        var tickTopY = (screenH * 0.21).toNumber();

        drawLargeTick(dc, centerX, tickTopY);

        dc.setColor(0x55D86A, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (screenH * 0.48).toNumber(),
            Graphics.FONT_SMALL,
            "Settings Reset",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (screenH * 0.62).toNumber(),
            Graphics.FONT_XTINY,
            "All values restored",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            (screenH * 0.70).toNumber(),
            Graphics.FONT_XTINY,
            "to default",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (screenH * 0.82).toNumber(),
            Graphics.FONT_XTINY,
            "press BACK to return",
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function drawLargeTick(dc as Dc, centerX, topY) {
        dc.setColor(0x55D86A, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(10);

        dc.drawLine(centerX - 34, topY + 32, centerX - 12, topY + 54);
        dc.drawLine(centerX - 12, topY + 54, centerX + 40, topY + 4);

        dc.setPenWidth(1);
    }

    // ---------------------------------------------------------
    // State helpers used by ResetSettingsDelegate
    // ---------------------------------------------------------

    function isOpenScreen() {
        return _screenState == 0;
    }

    function isConfirmScreen() {
        return _screenState == 1;
    }
}


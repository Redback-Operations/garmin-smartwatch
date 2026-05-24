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

        // Existing app settings
        app.setTargetCadence(160);
        app.setUserSpeed(0.0);
        app.setUserGender(0);
        app.setExperienceLvl(0.0);
        app.setChartDuration(10);
        app.setVibrationEnabled(true);

        // Required reset defaults
        Application.Storage.setValue("training_mode", "Warm Up");
        Application.Storage.setValue("summary_preferences", true);
        Application.Storage.setValue("profile_height", 0);
        Application.Storage.setValue("profile_speed", 0.0);
        Application.Storage.setValue("profile_gender", 0);
        Application.Storage.setValue("profile_experience", 0.0);

        app.saveSettings();

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
        var iconSize = 80;
        var iconY = (screenH / 2) - 92;

        dc.drawBitmap(centerX - (iconSize / 2), iconY, _resetIcon);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            iconY + 94,
            Graphics.FONT_MEDIUM,
            "Reset Settings",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            iconY + 132,
            Graphics.FONT_XTINY,
            "tap to open",
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
        var questionTop = (screenH / 2) - 125;

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
            questionTop + 34,
            Graphics.FONT_SMALL,
            "you want to reset",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            questionTop + 68,
            Graphics.FONT_SMALL,
            "all settings?",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        drawButtons(dc, questionTop + 125);
    }

    function drawButtons(dc as Dc, startY) {
        var centerX = dc.getWidth() / 2;

        var buttonW = 145;
        var buttonH = 34;
        var radius = 8;

        var buttonX = centerX - (buttonW / 2);

        var yesY = startY;
        var noY = startY + 48;

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
            y + 7,
            Graphics.FONT_XTINY,
            label,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    // ---------------------------------------------------------
    // SCREEN 3: Success screen
    // ---------------------------------------------------------

    function drawSuccessScreen(dc as Dc) {
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();

        var centerX = screenW / 2;

        var tickTopY = (screenH / 2) - 110;

        drawLargeTick(dc, centerX, tickTopY);

        dc.setColor(0x55D86A, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            tickTopY + 78,
            Graphics.FONT_SMALL,
            "Settings Reset",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            tickTopY + 122,
            Graphics.FONT_XTINY,
            "All values restored",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            tickTopY + 148,
            Graphics.FONT_XTINY,
            "to default",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            tickTopY + 198,
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
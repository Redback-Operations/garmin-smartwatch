import Toybox.Graphics;
import Toybox.WatchUi;

class SummarySettingsMenuView extends WatchUi.View {

    private var _screenState;
    private var _selectedButton;
    private var _resetIcon;

    function initialize() {
        View.initialize();

        _screenState = 0;
        _selectedButton = 0; // 0 = YES, 1 = NO
        _resetIcon = WatchUi.loadResource(Rez.Drawables.ResetIcon);
    }

    // 0 = Question Screen
    // 1 = Summary Screen

    // function onUpdate(dc as Dc) as Void {

    //     // Makes screen black and clears it
    //     dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    //     dc.clear();

    //     var centerX = dc.getWidth() / 2;
    //     var height = dc.getHeight();

    //     var icon = WatchUi.loadResource(Rez.Drawables.SummaryIcon);
    //     dc.drawBitmap(centerX - (icon.getWidth() / 2), (height * 0.25).toNumber(), icon);

    //     dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    //     dc.drawText(
    //         centerX,
    //         (height * 0.57).toNumber(),
    //         Graphics.FONT_MEDIUM,
    //         "Summary",
    //         Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    //     );

    //     dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    //     dc.drawText(
    //         centerX,
    //         (height * 0.72).toNumber(),
    //         Graphics.FONT_XTINY,
    //         "START to open",
    //         Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    //     );
    // }

        function onUpdate(dc as Dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        if (_screenState == 0) {
            drawSummaryOpenScreen(dc);
        } else if (_screenState == 1) {
            drawSummaryConfirmScreen(dc);
        }
        else if (_screenState == 2){
            WatchUi.pushView(
                new WorkOutSummarySettingsView(),
                new WorkOutSummarySettingsViewDelegate(),
                WatchUi.SLIDE_DOWN
            );
        }
    }

        function openConfirmScreen() {
        _screenState = 1;
        _selectedButton = 0;
        WatchUi.requestUpdate();
    }

        function drawSummaryConfirmScreen(dc as Dc) {
        var screenW = dc.getWidth();
        var screenH = dc.getHeight();

        var centerX = screenW / 2;

        // Question block
        var questionTop = (screenH * 0.19).toNumber();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            centerX,
            questionTop,
            Graphics.FONT_SMALL,
            "Do you",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            questionTop + (screenH * 0.10).toNumber(),
            Graphics.FONT_SMALL,
            "want to view",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            centerX,
            questionTop + (screenH * 0.20).toNumber(),
            Graphics.FONT_SMALL,
            "summary",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        drawButtons(dc, (screenH * 0.55).toNumber());
    }

function drawButtons(dc as Dc, startY) {
        var centerX = dc.getWidth() / 2;

        // Reduced width to ~38% so two buttons and a gap can fit horizontally
        var buttonW = (dc.getWidth() * 0.38).toNumber();
        var buttonH = (dc.getHeight() * 0.12).toNumber();
        var radius = 8;
        var spacing = 15; // Gap between the buttons

        // Calculate horizontal positions relative to the center
        var yesX = centerX - buttonW - (spacing / 2);
        var noX = centerX + (spacing / 2);

        // Both buttons now share the exact same Y coordinate
        var buttonY = startY;

        if (_selectedButton == 0) {
            drawButton(
                dc,
                yesX,
                buttonY,
                buttonW,
                buttonH,
                radius,
                Graphics.COLOR_DK_GRAY,
                Graphics.COLOR_WHITE,
                "YES"
            );

            drawButton(
                dc,
                noX,
                buttonY,
                buttonW,
                buttonH,
                radius,
                Graphics.COLOR_GREEN,
                Graphics.COLOR_BLACK,
                "NO"
            );
        } else {
            drawButton(
                dc,
                yesX,
                buttonY,
                buttonW,
                buttonH,
                radius,
                0x4A4A4A,
                Graphics.COLOR_WHITE,
                "YES"
            );

            drawButton(
                dc,
                noX,
                buttonY,
                buttonW,
                buttonH,
                radius,
                Graphics.COLOR_GREEN,
                Graphics.COLOR_BLACK,
                "NO"
            );
        }
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
                System.println("[BUTTON 0]");
                _screenState = 2;
            } else {
                _screenState = 0;
                System.println("[BUTTON 1]");
            }
            WatchUi.requestUpdate();
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

    function drawSummaryOpenScreen(dc as Dc) {
        // Makes screen black and clears it
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var centerX = dc.getWidth() / 2;
        var height = dc.getHeight();

        var icon = WatchUi.loadResource(Rez.Drawables.SummaryIcon);
        dc.drawBitmap(centerX - (icon.getWidth() / 2), (height * 0.25).toNumber(), icon);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.57).toNumber(),
            Graphics.FONT_MEDIUM,
            "Summary",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.72).toNumber(),
            Graphics.FONT_XTINY,
            "START to open",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
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

    function isOpenScreen() {
        return _screenState == 0;
    }

    function isConfirmScreen() {
        return _screenState == 1;
    }
}

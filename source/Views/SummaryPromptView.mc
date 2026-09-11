import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;

class SummaryPromptView extends WatchUi.View {

    private var _selectedOption = 0; // 0 = Yes, 1 = No

    function initialize() {
        View.initialize();

        var app = Application.getApp() as GarminApp;
        _selectedOption = app.getSummaryEnabled() ? 0 : 1;
    }

    function setSelectedOption(value) {
        _selectedOption = value;
    }

    function getSelectedOption() {
        return _selectedOption;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, (height * 0.27).toNumber(), Graphics.FONT_MEDIUM, "Show workout", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX, (height * 0.40).toNumber(), Graphics.FONT_MEDIUM, "summary?", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var buttonWidth = (width * 0.32).toNumber();
        var buttonHeight = (height * 0.14).toNumber();
        var buttonY = (height * 0.68).toNumber();
        drawButton(dc, centerX - (width * 0.20).toNumber(), buttonY, buttonWidth, buttonHeight, "YES", _selectedOption == 0);
        drawButton(dc, centerX + (width * 0.20).toNumber(), buttonY, buttonWidth, buttonHeight, "NO", _selectedOption == 1);
    }

    function drawButton(dc, centerX, centerY, buttonWidth, buttonHeight, label, selected) {
        var x = centerX - (buttonWidth / 2);
        var y = centerY - (buttonHeight / 2);

        if (selected) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_GREEN);
        } else {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_LT_GRAY);
        }

        dc.fillRectangle(x, y, buttonWidth, buttonHeight);

        dc.setColor(selected ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY, Graphics.FONT_SMALL, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

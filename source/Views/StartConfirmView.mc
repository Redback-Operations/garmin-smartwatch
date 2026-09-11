import Toybox.Graphics;
import Toybox.WatchUi;
using Rez;

class StartConfirmView extends WatchUi.View {

    private var _selectedOption = 0; // 0 = Yes, 1 = No

    function initialize() {
        View.initialize();
    }

    function setSelectedOption(value) {
        _selectedOption = value;
    }

    function getSelectedOption() {
        return _selectedOption;
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        
        var tickIcon = WatchUi.loadResource(Rez.Drawables.TickIcon);
        var crossIcon = WatchUi.loadResource(Rez.Drawables.CrossIcon);
        var recIcon = WatchUi.loadResource(Rez.Drawables.RecIcon);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawBitmap(centerX - (recIcon.getWidth() / 2), (height * 0.09).toNumber(), recIcon);
        dc.drawText(centerX, (height * 0.29).toNumber(), Graphics.FONT_SMALL, "Start recording?", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, (height * 0.40).toNumber(), Graphics.FONT_XTINY, "Choose an option", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var yesY = (height * 0.61).toNumber();
        var noY = (height * 0.78).toNumber();
        var pointerX = centerX - (width * 0.23).toNumber();
        var iconX = centerX - (width * 0.11).toNumber();
        var textX = centerX + (width * 0.05).toNumber();
        var iconOffsetY = (tickIcon.getHeight() / 2).toNumber();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawBitmap(iconX, yesY - iconOffsetY, tickIcon);
        dc.drawText(textX, yesY, Graphics.FONT_SMALL, "Yes", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        if (_selectedOption == 0) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.drawText(pointerX, yesY, Graphics.FONT_SMALL, ">", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawBitmap(iconX, noY - iconOffsetY, crossIcon);
        dc.drawText(textX, noY, Graphics.FONT_SMALL, "No", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        if (_selectedOption == 1) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(pointerX, noY, Graphics.FONT_SMALL, ">", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }
}

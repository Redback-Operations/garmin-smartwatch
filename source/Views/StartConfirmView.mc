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
    // Clear to black
    dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
    dc.clear();

    var width = dc.getWidth();

    var tickIcon = WatchUi.loadResource(Rez.Drawables.TickIcon);
    var crossIcon = WatchUi.loadResource(Rez.Drawables.CrossIcon);
    var recIcon = WatchUi.loadResource(Rez.Drawables.RecIcon);

    // Title row
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    var titleY = 110;
    var titleTextX = (width / 2) - 160;
    var recIconX = (width / 2) + 115;

    dc.drawText(
        titleTextX,
        titleY,
        Graphics.FONT_SYSTEM_SMALL,
        "Start recording?",
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.drawBitmap(recIconX, titleY - 25, recIcon);

    // Option row positions
    var yesY = 190;
    var noY = 245;

    var iconX = (width / 2) - 45;
    var textX = (width / 2) -15;

    var iconOffsetY = 14;

    // Yes option
    dc.drawBitmap(iconX, yesY - iconOffsetY, tickIcon);

    if (_selectedOption == 0) {
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    } else {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    }

    dc.drawText(
        textX,
        yesY,
        Graphics.FONT_SMALL,
        "Yes",
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );

    // No option
    dc.drawBitmap(iconX, noY - iconOffsetY, crossIcon);

    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);

    dc.drawText(
        textX,
        noY,
        Graphics.FONT_SMALL,
        "No",
        Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
}
}
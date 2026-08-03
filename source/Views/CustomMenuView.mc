import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Generic custom menu view compatible with API 1.2.0.
// Renders a scrollable list of items with a highlighted selection.
// Items are an Array of Dictionaries with :label and :id keys.
class CustomMenuView extends WatchUi.View {
    private var _title as String;
    private var _items as Array<Dictionary>;
    private var _selectedIndex as Number;
    private var _onSelect as Method;
    private var _onBack as Method;
    private var _footerHint as String;

    function initialize(title as String, items as Array<Dictionary>, onSelect as Method, onBack as Method, footerHint as String) {
        View.initialize();
        _title = title;
        _items = items;
        _selectedIndex = 0;
        _onSelect = onSelect;
        _onBack = onBack;
        _footerHint = footerHint;
    }

    function getSelectedIndex() as Number {
        return _selectedIndex;
    }

    function setSelectedIndex(index as Number) as Void {
        if (index >= 0 && index < _items.size()) {
            _selectedIndex = index;
        }
    }

    function moveUp() as Void {
        if (_selectedIndex > 0) {
            _selectedIndex--;
        } else {
            _selectedIndex = _items.size() - 1;
        }
        WatchUi.requestUpdate();
    }

    function moveDown() as Void {
        if (_selectedIndex < _items.size() - 1) {
            _selectedIndex++;
        } else {
            _selectedIndex = 0;
        }
        WatchUi.requestUpdate();
    }

    function activate() as Void {
        var id = _items[_selectedIndex][:id];
        _onSelect.invoke(id);
    }

    function handleBack() as Void {
        _onBack.invoke();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, 10, Graphics.FONT_SMALL, _title, Graphics.TEXT_JUSTIFY_CENTER);

        // Divider under title
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(20, 35, width - 20, 35);

        // Items
        var itemHeight = 40;
        var startY = 50;
        var itemWidth = width - 40;
        var itemX = 20;

        for (var i = 0; i < _items.size(); i++) {
            var y = startY + (i * itemHeight);
            var label = _items[i][:label] as String;

            if (i == _selectedIndex) {
                // Highlighted background
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(itemX, y, itemWidth, itemHeight - 6);
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }

            dc.drawText(centerX, y + 10, Graphics.FONT_MEDIUM, label, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Footer hint
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - 25, Graphics.FONT_XTINY, _footerHint, Graphics.TEXT_JUSTIFY_CENTER);
    }
}

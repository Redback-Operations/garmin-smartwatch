import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class ProfilePickerFactory extends WatchUi.PickerFactory {
    private var _start as Number;
    private var _stop as Number;
    private var _increment as Number;
    private var _label as String;

    function initialize(start as Number, stop as Number, increment as Number, options as Dictionary?) {
        PickerFactory.initialize();
        _start = start;
        _stop = stop;
        _increment = increment;
        _label = "";

        if (options != null) {
            if (options.hasKey(:label)) {
                _label = options[:label] as String;
            }
        }
    }

    function getSize() as Number {
        return (_stop - _start) / _increment + 1;
    }
 
    function getValue(index as Number) as Object? {
        return _start + (index * _increment);
    }

    function getDrawable(index as Number, selected as Boolean) as Drawable? {
        
        // gets the selected value
        var val = getValue(index);
        
        // converts to number if needed
        if (val has :toNumber) {
            val = val.toNumber();
        }

        // string that is displayed (e.g. "175" + " cm")
        var displayString = Lang.format("$1$$2$", [val, _label]);

        return new WatchUi.Text({
            :text => displayString, 
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_MEDIUM,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_CENTER
        });
    }

    function getIndex(value as Number) as Number {
        
        var safeValue = value;
        if (safeValue has :toNumber) {
            safeValue = safeValue.toNumber();
        }
        
        return (safeValue - _start) / _increment;
    }
}
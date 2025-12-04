import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class AdvancedViewDelegate extends WatchUi.InputDelegate { 
    
    private var _view as AdvancedView; 

    function initialize(view as AdvancedView) {
        InputDelegate.initialize();
        _view = view;
    }

    function onBack() as Boolean{
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
    
}
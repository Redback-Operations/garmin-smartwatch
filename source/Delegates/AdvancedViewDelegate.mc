import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class AdvancedViewDelegate extends WatchUi.BehaviorDelegate { 
    

    function initialize(view as AdvancedView) {
        BehaviorDelegate.initialize();
    }

    function onKey(keyEvent as WatchUi.KeyEvent){
        var key = keyEvent.getKey();


        //back to simpleView
        if(key == WatchUi.KEY_UP)
        {
            WatchUi.popView(WatchUi.SLIDE_UP);
        }
        return true;
    }

    
    function onSwipe(SwipeEvent as WatchUi.SwipeEvent){
        var direction = SwipeEvent.getDirection();
        
        //swipe back to simpleView
        if (direction == WatchUi.SWIPE_DOWN) {
            System.println("Swiped Up");
            WatchUi.popView(WatchUi.SLIDE_UP);
        }

        return true;
    }

    function onBack(){
        WatchUi.popView(WatchUi.SLIDE_BLINK);
        return true;
    }
    
}
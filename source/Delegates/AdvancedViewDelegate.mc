import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class AdvancedViewDelegate extends WatchUi.BehaviorDelegate { 
    

    function initialize(view as AdvancedView) {
        BehaviorDelegate.initialize();
    }

    function onMenu(){
        //called by the timer after 1s hold
        var menu = new WatchUi.Menu2({:resources => "menus/menu.xml"});

        WatchUi.pushView(new Rez.Menus.MainMenu(), new SelectCadenceDelegate(menu), WatchUi.SLIDE_BLINK);

        return true;

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
            return true;
        }

        if(direction == WatchUi.SWIPE_LEFT){
            var currentView = new SettingsView();
            System.println("Swiped Left");
            WatchUi.pushView(currentView, new SettingsDelegate(currentView), WatchUi.SLIDE_LEFT);
            return true;
        }

        return false;
    }

    function onBack(){
        WatchUi.popView(WatchUi.SLIDE_BLINK);
        return true;
    }
    
}
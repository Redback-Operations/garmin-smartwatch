import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class AdvancedViewDelegate extends WatchUi.BehaviorDelegate { 
    
    //private var _view as AdvancedView; 

    function initialize(view as AdvancedView) {
        InputDelegate.initialize();
        //_view = view;
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
            pushSettingsView();
            return true;
        }

        return false;
    }

    function onBack(){
        WatchUi.popView(WatchUi.SLIDE_BLINK);
        return true;
    }

        function pushSettingsView() as Void{
        var settingsMenu = new WatchUi.Menu2({ :title => "Settings" });

        settingsMenu.addItem(new WatchUi.MenuItem("Profile", null, :set_profile, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Customization", null, :cust_options, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Feedback", null, :feedback_options, null));
        settingsMenu.addItem(new WatchUi.MenuItem("Cadence Range", null, :cadence_range, null));

        WatchUi.pushView(settingsMenu, new SettingsMenuDelegate(), WatchUi.SLIDE_UP);
    }
    
}
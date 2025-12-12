import Toybox.Lang;
import Toybox.WatchUi;

class SimpleViewDelegate extends WatchUi.BehaviorDelegate {

    private var _currentView = null;

     function initialize() {
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

        if(key == WatchUi.KEY_UP)//block GarminControlMenu (the triangle screen)
        {
            return true;
        }

        if(key == WatchUi.KEY_DOWN){
            _currentView = new AdvancedView();

            // Switches the screen to advanced view by clocking down button
            WatchUi.pushView(_currentView, new AdvancedViewDelegate(_currentView), WatchUi.SLIDE_DOWN);
            return true;
        }

        return false;
    }


    function onSwipe(SwipeEvent as WatchUi.SwipeEvent){
        var direction = SwipeEvent.getDirection();
            
        if (direction == WatchUi.SWIPE_UP) {
            _currentView = new AdvancedView(); 
            System.println("Swiped Down");
            WatchUi.pushView(_currentView, new AdvancedViewDelegate(_currentView), WatchUi.SLIDE_DOWN);
            return true;
        }

        if(direction == WatchUi.SWIPE_LEFT){
            _currentView = new SettingsView();
            System.println("Swiped Left");
            WatchUi.pushView(_currentView, new SettingsDelegate(_currentView), WatchUi.SLIDE_LEFT);
            return true;
        }

        return false;
    }

    function onBack(){
        //dont pop view and exit app
        return true;
    }

}
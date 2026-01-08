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

    function onSelect() as Boolean {
        // Toggle recording on/off with SELECT button
        var app = getApp();
        
        if (app.isActivityRecording()) {
            // Show stop menu
            var menu = new WatchUi.Menu2({:title => "Stop Recording?"});
            menu.addItem(new WatchUi.MenuItem("Yes", null, :stop_yes, {}));
            menu.addItem(new WatchUi.MenuItem("No", null, :stop_no, {}));
            WatchUi.pushView(menu, new StopMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        } else {
            // Start recording immediately
            app.startRecording();
            WatchUi.requestUpdate();
        }
        
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

// Delegate for handling stop menu selection
class StopMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        
        if (id == :stop_yes) {
            // User selected YES to stop - show save menu
            var menu = new WatchUi.Menu2({:title => "Save Activity?"});
            menu.addItem(new WatchUi.MenuItem("Save", null, :save_yes, {}));
            menu.addItem(new WatchUi.MenuItem("Discard", null, :save_no, {}));
            WatchUi.pushView(menu, new SaveMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        } else if (id == :stop_no) {
            // User selected NO - continue recording
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
    
    function onBack() as Void {
        // BACK button cancels
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

// Delegate for handling save menu selection
class SaveMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        var app = getApp();
        
        if (id == :save_yes) {
            // Save the activity
            app.stopRecording();
            app.saveRecording();
        } else if (id == :save_no) {
            // Discard the activity
            app.stopRecording();
            app.discardRecording();
        }
        
        // Pop both menus (save and stop)
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate();
    }
    
    function onBack() as Void {
        // BACK button goes back to stop menu
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

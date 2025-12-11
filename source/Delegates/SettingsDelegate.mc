import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SettingsDelegate extends WatchUi.InputDelegate { 
    
    private var _view as SettingsView; 

    function initialize(view as SettingsView) {
        InputDelegate.initialize();
        _view = view;
    }


    function onBack() as Boolean{
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
    
    // This check for a tap on the screen
    function onTap(event as WatchUi.ClickEvent) as Boolean { 
        
        var x = 0; 
        var y = 0;
        
        // Use has check to safely retrieve coordinates from the event object.
        if (event has :getCoordinates) {
            // event.getCoordinates() returns Array<Number> [x, y].
            var tapCoords = event.getCoordinates() as Array<Number>;
            x = tapCoords[0]; 
            y = tapCoords[1];
        } else if (event has :getX) {
            // Fallback for devices without getCoordinates()
            x = 0;
            y = 0;
        }

        System.println(x.toString() + "and" + y.toString());
        
        // Get the button coordinates from the associated View
        var coords = _view.getButtonCoords();
        var x1 = coords[0];
        var y1 = coords[1];
        var x2 = coords[2];
        var y2 = coords[3];

        System.println(x1.toString() + " " + y1.toString() + " " + x2.toString() + " " + y2.toString());
        
        // Check if the tap was on the button and sends to cadence range select menu
        if (x >= x1 && x <= x1 + x2 && y >= y1 && y <= y1 + y2) {
            System.println("Button Pressed");

            
            var app = Application.getApp() as GarminApp;
            var minCadence = app.getMinCadence();
            var maxCadence = app.getMaxCadence();

            var menu = new WatchUi.Menu2({
                :title => Lang.format("Cadence: $1$ - $2$", [minCadence, maxCadence])
            });

            // these are def in strings.xml
            menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_inc_min), null, :item_inc_min, null));
            menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_dec_min), null, :item_dec_min, null));
            menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_inc_max), null, :item_inc_max, null));
            menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_dec_max), null, :item_dec_max, null));

            // push the menu made above with selectcadencedelegate 
            WatchUi.pushView(menu, new SelectCadenceDelegate(menu), WatchUi.SLIDE_LEFT);
            
            return true;
        }
        
        return false;
    }
}
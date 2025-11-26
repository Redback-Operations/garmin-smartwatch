import Toybox.Lang;
import Toybox.WatchUi;

class TestingCadenceDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new TestingCadenceMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}
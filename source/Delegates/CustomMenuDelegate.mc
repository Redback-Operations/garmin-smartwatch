import Toybox.Lang;
import Toybox.WatchUi;

// Generic custom menu delegate compatible with API 1.2.0.
// Handles UP/DOWN navigation, SELECT/TAP activation, and BACK.
class CustomMenuDelegate extends WatchUi.BehaviorDelegate {
    private var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // UP button (or swipe up)
    function onPreviousPage() as Boolean {
        _view.moveUp();
        return true;
    }

    // DOWN button (or swipe down)
    function onNextPage() as Boolean {
        _view.moveDown();
        return true;
    }

    // Physical key support
    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_UP) {
            _view.moveUp();
            return true;
        } else if (key == WatchUi.KEY_DOWN) {
            _view.moveDown();
            return true;
        } else if (key == WatchUi.KEY_ENTER) {
            _view.activate();
            return true;
        }
        return false;
    }

    // SELECT / START button
    function onSelect() as Boolean {
        _view.activate();
        return true;
    }

    // Screen tap
    function onTap(evt) as Boolean {
        _view.activate();
        return true;
    }

    // BACK button
    function onBack() as Boolean {
        _view.handleBack();
        return true;
    }
}

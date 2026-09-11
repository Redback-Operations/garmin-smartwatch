import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class SummarySettingsMenuDelegate extends WatchUi.BehaviorDelegate { 

    private var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() {
        _view.selectCurrentOption();
        return true;
    }

    function onTap(evt) {
        _view.selectCurrentOption();
        return true;
    }

    // Handles the DOWN button (or swipe up)
    function onNextPage() {
        handleDown();
        return true;
    }

    // Handles the UP button (or swipe down)
    function onPreviousPage() {
        handleUp();
        return true;
    }

    function onBack() {
        _view.handleBack();
        return true;
    }

    function handleUp() {
        if (_view.isConfirmScreen()) {
            _view.moveSelectionUp();
            return;
        }

        if (_view.isOpenScreen()) {
            System.println("Up button pressed: Opening Profile Settings");

            WatchUi.pushView(
                new ProfileSettingsMenuView(),
                new ProfileSettingsMenuDelegate(),
                WatchUi.SLIDE_DOWN
            );
        }
        return;
    }

    function handleDown() {
        if (_view.isConfirmScreen()) {
            _view.moveSelectionDown();
            return;
        }

        // First Reset screen: DOWN goes to Cadence Settings
        if (_view.isOpenScreen()) {
            System.println("Down button pressed: Opening Bar Chart Settings");

            WatchUi.switchToView(
                new BarChartSettingsMenuView(),
                new BarChartSettingsMenuDelegate(),
                WatchUi.SLIDE_UP);
        }
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_UP) {
            handleUp();
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            handleDown();
            return true;
        }

        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START || key == WatchUi.KEY_MENU) {
            _view.selectCurrentOption();
            return true;
        }

        return false;
    }
}

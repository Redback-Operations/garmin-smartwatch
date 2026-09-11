import Toybox.WatchUi;
import Toybox.System;

class ResetSettingsDelegate extends WatchUi.BehaviorDelegate {

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

    // DOWN button
    function onNextPage() {
        handleDown();
        return true;
    }

    // UP button
    function onPreviousPage() {
        handleUp();
        return true;
    }

    // Physical key support for simulator/device
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

    function handleUp() {
        if (_view.isConfirmScreen()) {
            _view.moveSelectionUp();
            return;
        }

        if (_view.isOpenScreen()) {
            System.println("Up button pressed: Opening Bar Chart Settings");

            WatchUi.pushView(
                new BarChartSettingsMenuView(),
                new BarChartSettingsMenuDelegate(),
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
            System.println("Down button pressed: Opening Vibration On Settings");

            WatchUi.pushView(
                new VibrationsOnSettingsView(),
                new VibrationsOnSettingsMenuDelegate(),
                WatchUi.SLIDE_UP
            );
            return;
        }
    }

    function onBack() {
        _view.handleBack();
        return true;
    }
}
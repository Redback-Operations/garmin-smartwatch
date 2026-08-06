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
        // Confirmation screen: UP selects YES
        if (_view.isConfirmScreen()) {
            _view.moveSelectionUp();
            return;
        }

        // First Reset screen: UP goes back to Summary Settings
        if (_view.isOpenScreen()) {
            System.println("UP pressed from Reset: Summary Settings");

            WatchUi.pushView(
                new SummarySettingsMenuView(),
                new SummarySettingsMenuDelegate(),
                WatchUi.SLIDE_DOWN
            );

            return;
        }
    }

    function handleDown() {
        // Confirmation screen: DOWN selects NO
        if (_view.isConfirmScreen()) {
            _view.moveSelectionDown();
            return;
        }

        // First Reset screen: DOWN goes to Cadence Settings
        if (_view.isOpenScreen()) {
            System.println("DOWN pressed from Reset: Cadence Settings");

            WatchUi.pushView(
                new CadenceSettingsMenuView(),
                new CadenceSettingsMenuDelegate(),
                WatchUi.SLIDE_UP
            );

            return;
        }
    }

    function onBack() {
        pushSettingsView();

        return true;
    }

    function pushSettingsView() as Void {
        WatchUi.switchToView(new SettingsView(), new SettingsMenuDelegate(), WatchUi.SLIDE_UP);
    }
}
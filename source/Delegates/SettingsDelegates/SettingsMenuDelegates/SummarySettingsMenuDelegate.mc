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
        handleSelect();
        return true;
    }

    function onTap(evt) {
        handleSelect();
        return true;
    }

    function handleSelect() {
        _view.selectCurrentOption();
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
        if (_view.isOpenScreen()) {
            System.println("Back pressed: Returning to previous view");
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else {
            _view.handleBack();
        }
        return true;
    }

    function handleUp() {
        if (_view.isConfirmScreen()) {
            _view.moveSelectionUp();
            return;
        }

        if (_view.isOpenScreen()) {
            System.println("Up button pressed: Opening Bar Chart Settings");

            WatchUi.switchToView(
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

        if (_view.isOpenScreen()) {
            System.println("Down button pressed: Opening Reset Settings");

            var resetView = new ResetSettingsView();
            WatchUi.switchToView(
                resetView,
                new ResetSettingsDelegate(resetView),
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
            handleSelect();
            return true;
        }

        return false;
    }
}

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

    function handleUp() {
        // Confirmation screen: UP selects YES
        if (_view.isConfirmScreen()) {
            _view.moveSelectionUp();
            return;
        }

        // First Reset screen: UP goes back to Summary Settings
        if (_view.isOpenScreen()) {
            ScreenNavigation.showPreviousSettingsPage(ScreenNavigation.SETTINGS_RESET);
            return;
        }
    }

    function handleDown() {
        // Confirmation screen: DOWN selects NO
        if (_view.isConfirmScreen()) {
            _view.moveSelectionDown();
            return;
        }

        // First Reset screen: DOWN wraps to the Settings page.
        if (_view.isOpenScreen()) {
            ScreenNavigation.showNextSettingsPage(ScreenNavigation.SETTINGS_RESET);
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

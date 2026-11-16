import Toybox.WatchUi;
import Toybox.System;

class StartConfirmViewDelegate extends WatchUi.BehaviorDelegate {

private var _confirmView;

    function initialize(confirmView) {
        BehaviorDelegate.initialize();
        _confirmView = confirmView;
    }

    // Handles physical Up/Down buttons
    function onKey(keyEvent) {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_UP) {
            _confirmView.setSelectedOption(0); // Select YES
            WatchUi.requestUpdate();
            return true;
        }

        if (key == WatchUi.KEY_DOWN) {
            _confirmView.setSelectedOption(1); // Select NO
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }

    // Handles touchscreen swipes
    function onSwipe(event) {
        var direction = event.getDirection();

        if (direction == WatchUi.SWIPE_DOWN) {
            _confirmView.setSelectedOption(0); // Swiping down moves selection UP to YES
            WatchUi.requestUpdate();
            return true;
        }

        if (direction == WatchUi.SWIPE_UP) {
            _confirmView.setSelectedOption(1); // Swiping up moves selection DOWN to NO
            WatchUi.requestUpdate();
            return true;
        }

        return false;
    }

    function onSelect() {
        var app = getApp();

        if (_confirmView.getSelectedOption() == 0) {
            // YES Selected - Start recording and close the menu.
            if (!app.startRecording()) {
                System.println("[UI] Activity could not be started; staying on confirmation screen");
                WatchUi.requestUpdate();
                return true;
            }
            System.println("[UI] Activity started from confirmation screen");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.requestUpdate();
        } else {
            // NO Selected - Just close the menu.
            System.println("[UI] Start recording cancelled");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }

        return true;
    }

    function onBack() {
        System.println("[UI] Back pressed - returning to main screen");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

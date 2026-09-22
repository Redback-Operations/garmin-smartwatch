import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;

class AdvancedViewDelegate extends WatchUi.BehaviorDelegate { 

    private var _upPressStartTime = 0;
    private var _lastUpReleaseTime = 0;
    private var _doubleClickThreshold = 600;
    private var _longPressThreshold = 800;

    function initialize(view as AdvancedView) {
        BehaviorDelegate.initialize();
    }

    function getTimeMs() as Number {
        return System.getTimer();
    }

    function onMenu() as Boolean {
        // Open settings menu from advanced view long press UP
        pushSettingsView();
        _lastUpReleaseTime = 0; 
        return true;
    }

    function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_UP) {
            _upPressStartTime = getTimeMs();
            return true;
        }

        return false;
    }

    function onKeyReleased(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        var currentTime = getTimeMs();

        if (key == WatchUi.KEY_UP) {
            var pressDuration = currentTime - _upPressStartTime;

            // 1. IS IT A LONG PRESS?
            if (pressDuration >= _longPressThreshold) {
                System.println("[AdvancedView] Long press UP -> Settings");
                pushSettingsView();
                _lastUpReleaseTime = 0; 
                return true;
            }

            // 2. IS IT A DOUBLE CLICK?
            if (_lastUpReleaseTime != 0 && (currentTime - _lastUpReleaseTime) < _doubleClickThreshold) {
                System.println("[AdvancedView] Double click UP -> Vibration Toggle");
                toggleVibration();
                _lastUpReleaseTime = 0; 
                return true;
            }

            // 3. IT IS A SINGLE CLICK (Wait for double, or let them swipe/press down to leave)
            System.println("[AdvancedView] Single click UP -> Waiting for double...");
            _lastUpReleaseTime = currentTime;
            return true;
        }

        // HANDLE DOWN BUTTON (Single click to go back to SimpleView)
        if (key == WatchUi.KEY_DOWN) {
            pushSimpleView();
            return true;
        }

        return false;
    }

    function toggleVibration() as Void {
        var app = Application.getApp() as GarminApp;
        
        var enabled = app.getVibrationEnabled();
        var newEnabled = !enabled;
        
        app.setVibrationEnabled(newEnabled);

        System.println("[AdvancedView] Vibration toggled: " + newEnabled.toString());

        // Push the VibrationView using the boolean (since your initialize expects true/false)
        WatchUi.pushView(
            new VibrationView(newEnabled),
            new WatchUi.BehaviorDelegate(), // basic delegate so it can auto-close or be backed out of
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Boolean {
        var direction = swipeEvent.getDirection();
        
        // Swipe DOWN - Back to SimpleView, sliding down to match the gesture
        if (direction == WatchUi.SWIPE_DOWN) {
            System.println("[UI] Swiped down to SimpleView");
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }

        // Swipe UP - Back to SimpleView, sliding up to match the gesture
        if (direction == WatchUi.SWIPE_UP) {
            System.println("[UI] Swiped up to SimpleView");
            WatchUi.popView(WatchUi.SLIDE_UP);
            return true;
        }

        // Swipe LEFT - Settings
        if (direction == WatchUi.SWIPE_LEFT) {
            pushSettingsView();
            return true;
        }

        return false;
    }

    function onBack() as Boolean {
        pushSimpleView();
        return true;
    }

    function pushSettingsView() as Void {
        WatchUi.switchToView(new SettingsView(), new SettingsMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function pushSimpleView() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

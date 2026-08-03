import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Timer;

class SimpleViewDelegate extends WatchUi.BehaviorDelegate {

    private var _currentView = null;
    private var _initTime = null;
    private var _menuActive = false;

    // button timing variables
    private var _lastUpReleaseTime = 0;
    private var _doubleClickThreshold = 600;
    private var _longPressThreshold = 800;
    
    // Timer variables
    private var _longPressTimer = null;
    private var _handledLongPress = false;

    function initialize() {
        BehaviorDelegate.initialize();
        _initTime = getTimeMs();
    }

    function getTimeMs() as Number {
        return System.getTimer();
    }

    function onMenu() as Boolean {
        // Full Reset of button states to prevent bugs if they open the menu
        _lastUpReleaseTime = 0;
        return true;
    }

    function onSelect() as Boolean {
        System.println("[DEBUG] onSelect called, menuActive=" + _menuActive);
        
        if (_initTime != null && (getTimeMs() - _initTime) < 1000) {
            System.println("[DEBUG] Ignoring onSelect during initialization");
            return false;
        }

        if (_menuActive) {
            System.println("[DEBUG] Menu active, letting menu delegate handle it");
            return false;
        }
        
        System.println("[DEBUG] Handling START/STOP button press");
        return handleStartStopButton();
    }

    function handleStartStopButton() as Boolean {
        var app = getApp();

        if (app.isIdle()) {
            var view = new StartConfirmView();
            WatchUi.pushView(view, new StartConfirmViewDelegate(view), WatchUi.SLIDE_UP);
            WatchUi.requestUpdate();
        } 
        else if (app.isRecording()) {
            _menuActive = true;
            showActivityControlMenu();
        } 
        else if (app.isPaused()) {
            _menuActive = true;
            showPausedControlMenu();
        }
        else if (app.isStopped()) {
            _menuActive = true;
            showSaveDiscardMenu();
        }
        return true;
    }

    function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_UP) {
            // 1. Reset the flag
            _handledLongPress = false;
            
            // 2. Start the stopwatch timer
            _longPressTimer = new Timer.Timer();
            _longPressTimer.start(method(:triggerLongPress), _longPressThreshold, false); 
            return true;
        }

        return false;
    }

    // This function fires instantly while the button is still held down
    function triggerLongPress() as Void {
        System.println("[DEBUG] Long press UP detected (Live) -> Settings");
        _handledLongPress = true; // Tell onKeyReleased to ignore the upcoming release
        _lastUpReleaseTime = 0;   // Reset double click math
        pushSettingsView();
    }

    function onKeyReleased(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        var currentTime = getTimeMs();

        //  HANDLE UP BUTTON
        if (key == WatchUi.KEY_UP) {
            
            // 1. Cancel the timer! If they let go before the threshold, stop it from firing.
            if (_longPressTimer != null) {
                _longPressTimer.stop();
                _longPressTimer = null;
            }

            // 2. If the long press already triggered, do NOTHING on release.
            if (_handledLongPress) {
                _handledLongPress = false; // Reset for next time
                return true;
            }

            // is a short click after this

            // 3. IS IT A DOUBLE CLICK?
            if (_lastUpReleaseTime != 0 && (currentTime - _lastUpReleaseTime) < _doubleClickThreshold) {
                System.println("[DEBUG] Double click UP detected -> Vibration Toggle");
                toggleVibration();
                _lastUpReleaseTime = 0; 
                return true;
            }

            // 4. IT IS A SINGLE CLICK
            System.println("[DEBUG] Single click UP -> Waiting for double...");
            _lastUpReleaseTime = currentTime;
            return true;
        }

        //  HANDLE DOWN BUTTON
        if (key == WatchUi.KEY_DOWN) {
            _currentView = new AdvancedView();
            WatchUi.pushView(
                _currentView,
                new AdvancedViewDelegate(_currentView),
                WatchUi.SLIDE_DOWN
            );
            return true;
        }

        return false;
    }

    function toggleVibration() as Void {
        var app = getApp();
        
        var enabled = app.getVibrationEnabled();
        var newEnabled = !enabled;
        app.setVibrationEnabled(newEnabled);

        var statusText = newEnabled ? "Vibration ON" : "Vibration OFF";
        System.println("[UI] " + statusText);

        WatchUi.pushView(
            new VibrationView(newEnabled), 
            new WatchUi.BehaviorDelegate(), 
            WatchUi.SLIDE_UP 
        );
    }

    function onSwipe(event as WatchUi.SwipeEvent) as Boolean {
        var direction = event.getDirection();

        if (direction == WatchUi.SWIPE_UP) {
            _currentView = new AdvancedView();
            WatchUi.pushView(
                _currentView,
                new AdvancedViewDelegate(_currentView),
                WatchUi.SLIDE_DOWN
            );
            return true;
        }
        return false;
    }

function showActivityControlMenu() as Void {
        var items = [
            { :label => "Resume", :id => :resume_activity },
            { :label => "Pause", :id => :pause_activity },
            { :label => "Stop", :id => :stop_activity }
        ];
        var menu = new CustomMenuView("Activity", items, method(:onActivityMenuItem), method(:onActivityMenuBack), "UP/DOWN select, START confirm");
        WatchUi.pushView(menu, new CustomMenuDelegate(menu), WatchUi.SLIDE_UP);
    }

    function showPausedControlMenu() as Void {
        var items = [
            { :label => "Resume", :id => :resume_activity },
            { :label => "Stop", :id => :stop_activity }
        ];
        var menu = new CustomMenuView("Activity Paused", items, method(:onActivityMenuItem), method(:onActivityMenuBack), "UP/DOWN select, START confirm");
        WatchUi.pushView(menu, new CustomMenuDelegate(menu), WatchUi.SLIDE_UP);
    }

    function showSaveDiscardMenu() as Void {
        var items = [
            { :label => "Save", :id => :save_session },
            { :label => "Discard", :id => :discard_session }
        ];
        var menu = new CustomMenuView("Save Activity?", items, method(:onActivityMenuItem), method(:onActivityMenuBack), "UP/DOWN select, START confirm");
        WatchUi.pushView(menu, new CustomMenuDelegate(menu), WatchUi.SLIDE_UP);
    }

    // Callback for custom menu item selection (replaces ActivityControlMenuDelegate/SaveDiscardMenuDelegate)
    function onActivityMenuItem(id as Symbol) as Void {
        var app = getApp();
        System.println("[DEBUG] Menu item selected: " + id);

        if (id == :pause_activity) {
            app.pauseRecording();
            System.println("[UI] Activity paused");
            _menuActive = false;
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.requestUpdate();
        } else if (id == :resume_activity) {
            if (app.isPaused()) {
                app.resumeRecording();
                System.println("[UI] Activity resumed");
            }
            _menuActive = false;
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.requestUpdate();
        } else if (id == :stop_activity) {
            app.stopRecording();
            System.println("[UI] Activity stopped");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            _menuActive = false;
            showSaveDiscardMenu();
        } else if (id == :save_session) {
            app.saveSession();
            System.println("[UI] Activity saved");
            _menuActive = false;

            if (app.getSummaryEnabled()) {
                WatchUi.switchToView(
                    new SummaryView(),
                    new SummaryViewDelegate(),
                    WatchUi.SLIDE_UP
                );
            } else {
                System.println("[UI] Summary screen skipped by user preference");
                WatchUi.switchToView(
                    new SimpleView(),
                    new SimpleViewDelegate(),
                    WatchUi.SLIDE_DOWN
                );
            }
        } else if (id == :discard_session) {
            app.discardSession();
            System.println("[UI] Activity discarded");
            _menuActive = false;
            showDiscardConfirmation();
        }
        WatchUi.requestUpdate();
    }

    // Callback for custom menu BACK (replaces onBack in Menu2 delegates)
    function onActivityMenuBack() as Void {
        _menuActive = false;
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    // Discard confirmation screen (replaces ConfirmationDelegate Menu2)
    function showDiscardConfirmation() as Void {
        var items = [
            { :label => "Done", :id => :done }
        ];
        var menu = new CustomMenuView("Activity Discarded", items, method(:onDiscardConfirmationItem), method(:onDiscardConfirmationBack), "START to continue");
        WatchUi.pushView(menu, new CustomMenuDelegate(menu), WatchUi.SLIDE_IMMEDIATE);
    }

    function onDiscardConfirmationItem(id as Symbol) as Void {
        _menuActive = false;
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onDiscardConfirmationBack() as Void {
        _menuActive = false;
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function pushSettingsView() as Void {
        WatchUi.switchToView(new SettingsView(), new SettingsMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function setMenuActive(active as Boolean) as Void {
        _menuActive = active;
        System.println("[DEBUG] Menu active state set to: " + active);
    }

    function onBack() as Boolean {
        var app = getApp();

        if (app.isRecording() || app.isPaused() || app.isStopped()) {
            //System.println("[UI] Session active - use Stop to exit");
           System.println("[UI] Finish or discard current session first");
           return true;
        }

        // FULL RESET TO SIMPLE VIEW
        WatchUi.switchToView(
            new SimpleView(),
            new SimpleViewDelegate(),
            WatchUi.SLIDE_IMMEDIATE
        );

return true;
    }
}

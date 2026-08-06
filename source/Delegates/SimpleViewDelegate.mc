import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class SimpleViewDelegate extends WatchUi.BehaviorDelegate {

    private var _currentView = null;
    private var _initTime = null;
    private var _menuActive = false;

    // button timing variables
    private var _lastUpReleaseTime = 0;
    private var _upPressStartTime = 0;
    private var _doubleClickThreshold = 600;
    private var _longPressThreshold = 800;

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
            _upPressStartTime = getTimeMs();
            return true;
        }

        return false;
    }

    function onKeyReleased(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        var currentTime = getTimeMs();

        //  HANDLE UP BUTTON
        if (key == WatchUi.KEY_UP) {
            var pressDuration = currentTime - _upPressStartTime;

            // Detect long presses from elapsed time so input handling never
            // allocates a second Timer.Timer beside the screen refresh timer.
            if (pressDuration >= _longPressThreshold) {
                System.println("[DEBUG] Long press UP detected -> Settings");
                _lastUpReleaseTime = 0;
                pushSettingsView();
                return true;
            }

            // is a short click after this

            // IS IT A DOUBLE CLICK?
            if (_lastUpReleaseTime != 0 && (currentTime - _lastUpReleaseTime) < _doubleClickThreshold) {
                System.println("[DEBUG] Double click UP detected -> Vibration Toggle");
                toggleVibration();
                _lastUpReleaseTime = 0; 
                return true;
            }

            // IT IS A SINGLE CLICK
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
        var menu = new WatchUi.Menu2({ :title => "Activity" });
        menu.addItem(new WatchUi.MenuItem("Resume", "Continue", :resume_activity, null));
        menu.addItem(new WatchUi.MenuItem("Pause", "Pause activity", :pause_activity, null));
        menu.addItem(new WatchUi.MenuItem("Stop", "Stop activity", :stop_activity, null));
        
        WatchUi.pushView(menu, new ActivityControlMenuDelegate(self), WatchUi.SLIDE_UP);
    }

    function showPausedControlMenu() as Void {
        var menu = new WatchUi.Menu2({ :title => "Activity Paused" });
        menu.addItem(new WatchUi.MenuItem("Resume", "Continue", :resume_activity, null));
        menu.addItem(new WatchUi.MenuItem("Stop", "Stop activity", :stop_activity, null));
        
        WatchUi.pushView(menu, new ActivityControlMenuDelegate(self), WatchUi.SLIDE_UP);
    }

    function showSaveDiscardMenu() as Void {
        var menu = new WatchUi.Menu2({ :title => "Save Activity?" });
        menu.addItem(new WatchUi.MenuItem("Save", "Save session", :save_session, null));
        menu.addItem(new WatchUi.MenuItem("Discard", "Discard session", :discard_session, null));
        
        WatchUi.pushView(menu, new SaveDiscardMenuDelegate(self), WatchUi.SLIDE_UP);
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

class ActivityControlMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    private var _parentDelegate;

    function initialize(parentDelegate) {
        Menu2InputDelegate.initialize();
        _parentDelegate = parentDelegate;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        var app = getApp();

        System.println("[DEBUG] Menu item selected: " + id);

        if (id == :pause_activity) {
            app.pauseRecording();
            System.println("[UI] Activity paused");
            _parentDelegate.setMenuActive(false);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.requestUpdate();
            
        } else if (id == :resume_activity) {
            if (app.isPaused()) {
                app.resumeRecording();
                System.println("[UI] Activity resumed");
            }
            _parentDelegate.setMenuActive(false);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.requestUpdate();
            
        } else if (id == :stop_activity) {
            app.stopRecording();
            System.println("[UI] Activity stopped");
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            _parentDelegate.setMenuActive(false);
            
            var menu = new WatchUi.Menu2({ :title => "Save Activity?" });
            menu.addItem(new WatchUi.MenuItem("Save", "Save session", :save_session, null));
            menu.addItem(new WatchUi.MenuItem("Discard", "Discard session", :discard_session, null));
            WatchUi.pushView(menu, new SaveDiscardMenuDelegate(_parentDelegate), WatchUi.SLIDE_UP);
        }
    }

    function onBack() as Void {
        _parentDelegate.setMenuActive(false);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

class SaveDiscardMenuDelegate extends WatchUi.Menu2InputDelegate {
    
    private var _parentDelegate;

    function initialize(parentDelegate) {
        Menu2InputDelegate.initialize();
        _parentDelegate = parentDelegate;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        var app = getApp();

        System.println("[DEBUG] Save/Discard selected: " + id);

        if (id == :save_session) {
             app.saveSession();
             System.println("[UI] Activity saved");
            _parentDelegate.setMenuActive(false);

            if (app.getSummaryEnabled()) {
                // SHOW SUMMARY SCREEN ON SAVE
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
            _parentDelegate.setMenuActive(false);
            
            var confirmationMenu = new WatchUi.Menu2({ :title => "Activity Discarded" });
            confirmationMenu.addItem(new WatchUi.MenuItem("Done", null, :done, null));
            WatchUi.pushView(confirmationMenu, new ConfirmationDelegate(_parentDelegate), WatchUi.SLIDE_IMMEDIATE);
        }
        
        WatchUi.requestUpdate();
    }

    function onBack() as Void {
        // Intentionally blank so they have to choose Save or Discard
    }
}

class ConfirmationDelegate extends WatchUi.Menu2InputDelegate {
    
    private var _parentDelegate;

    function initialize(parentDelegate) {
        Menu2InputDelegate.initialize();
        _parentDelegate = parentDelegate;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        _parentDelegate.setMenuActive(false);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
    
    function onBack() as Void {
        _parentDelegate.setMenuActive(false);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

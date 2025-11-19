import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;

class TestingCadenceView extends WatchUi.View {

    private var _cadenceDisplay;
    private var _refreshTimer;
    private var _heartrateDisplay;

    function initialize() {
        View.initialize();
        _refreshTimer = new Timer.Timer();
        _refreshTimer.start(method(:refreshScreen), 1000, true);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        _cadenceDisplay = findDrawableById("cadence_text");
        _heartrateDisplay = findDrawableById("heartrate_text");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        //update the display for current cadence
        displayCadence();
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function refreshScreen() as Void{
        WatchUi.requestUpdate();
    }

    function displayCadence() as Void{
        var info = Activity.getActivityInfo();
        

        if (info != null && info.currentCadence != null){
            _cadenceDisplay.setText(info.currentCadence.toString());
        }else{
            _cadenceDisplay.setText("--");
        }

        if (info != null && info.currentHeartRate != null){
            _heartrateDisplay.setText(info.currentHeartRate.toString());
        }else{
            _heartrateDisplay.setText("--");
        }
        
    }

}

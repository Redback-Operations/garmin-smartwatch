import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;

class TimeView extends WatchUi.View {
    private var _isAwake as Boolean = false;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _isAwake = true;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        
        // Format: "Sat 25 Jan"
        (View.findDrawableById("Date") as WatchUi.Text).setText(
            dayNames[date.day_of_week - 1] + " " + date.day.format("%2d") + " " + monthNames[date.month - 1]
        );
        // Convert to 12-hour format with AM/PM
        var hour12 = date.hour % 12;
        if (hour12 == 0) {
            hour12 = 12;
        }
        var ampm = (date.hour < 12) ? "AM" : "PM";
        (View.findDrawableById("HoursAndMinutes") as WatchUi.Text).setText(
            hour12.format("%02d") + ":" + date.min.format("%02d")
        );
        (View.findDrawableById("AmPm") as WatchUi.Text).setText(ampm);



        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        _isAwake = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        _isAwake = false;
    }
}

import Toybox.Lang;
import Toybox.System;

// Simple, crash-safe logger — plain println wrapper only.
// Deliberately kept dumb: no Storage, no Time, no try/catch chains.
// (An earlier version tried to do too much and crashed the app on startup.)
module Logger {
    function log(tag as String, message as String) as Void {
        System.println("[" + tag + "] " + message);
    }
}

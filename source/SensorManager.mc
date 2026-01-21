using Toybox.Activity;
using Toybox.System;
using Toybox.Lang;

class SensorManager {

    // -----------------------
    // Static configuration
    // -----------------------

    // Use simulator mode by default
    static var useSimulator = true;

    // Simulated cadence value for testing
    static var simulatedCadence = 0;

    // -----------------------
    // Public Methods
    // -----------------------

    // Set simulated cadence (for testing)
    public static function setSimCadence(value) {
        if (value == null || !(value instanceof Lang.Number)) {
            System.println("[SensorManager] ERROR: simulated cadence must be a number");
            return;
        }

        SensorManager.simulatedCadence = value;
        System.println("[SensorManager] Simulated cadence set to: " + SensorManager.simulatedCadence.toString());
    }

    // Switch mode between simulator and real sensor
    public static function setMode(simulator) {
        // No strict type check needed
        SensorManager.useSimulator = simulator ? true : false;
        System.println("[SensorManager] Mode set to: " + (SensorManager.useSimulator ? "SIM" : "REAL"));
    }

    // Get current cadence
    public static function getCadence() {
        var cadence = 0;

        if (SensorManager.useSimulator) {
            cadence = SensorManager.simulatedCadence;
            System.println("[SensorManager] Returning SIM cadence: " + cadence);
        } else {
            var info = Activity.getActivityInfo();
            if (info != null && info.currentCadence != null) {
                cadence = info.currentCadence;
                System.println("[SensorManager] Returning REAL cadence: " + cadence);
            } else {
                System.println("[SensorManager] REAL cadence unavailable, returning 0");
            }
        }

        return cadence;
    }
}
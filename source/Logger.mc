import Toybox.Lang;
import Toybox.System;

/**
 * Simple logger for memory monitoring only
 */
module Logger {
    
    /**
     * Log memory statistics
     */
    function logMemoryStats(tag as String) as Void {
        try {
            var stats = System.getSystemStats();
            var usedMemory = stats.totalMemory - stats.freeMemory;
            var memoryPercent = (usedMemory.toFloat() / stats.totalMemory.toFloat() * 100).toNumber();
            
            System.println("[MEMORY] " + tag + ": " + usedMemory + "/" + stats.totalMemory + 
                " bytes (" + memoryPercent + "% used)");
        } catch (e) {
            System.println("[ERROR] Failed to log memory stats: " + e.getErrorMessage());
        }
    }
}
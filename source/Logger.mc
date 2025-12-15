import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Activity;

/**
 * Logger module for debugging, system events, and crash logging
 * Logs are stored in persistent storage and can be retrieved for analysis
 */
module Logger {
    
    enum LogLevel {
        DEBUG = 0,
        INFO = 1,
        WARNING = 2,
        ERROR = 3,
        CRITICAL = 4
    }

    const MAX_LOG_ENTRIES = 100;  // Maximum number of log entries to keep
    const LOG_STORAGE_KEY = "app_logs";
    const CRASH_LOG_KEY = "crash_logs";
    const SESSION_START_KEY = "session_start";
    
    var currentSession as String = "";
    var logBuffer as Array<String> = [];
    var logCount = 0;

    /**
     * Initialize the logger system
     */
    function initialize() as Void {
        currentSession = generateSessionId();
        logBuffer = [];
        logCount = 0;
        
        // Log session start
        log(INFO, "Logger", "Session started: " + currentSession);
        logSystemInfo();
        
        // Store session start time
        Storage.setValue(SESSION_START_KEY, Time.now().value());
    }

    /**
     * Generate a unique session identifier
     */
    function generateSessionId() as String {
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);
        return info.year.format("%04d") + info.month.format("%02d") + info.day.format("%02d") + 
               "_" + info.hour.format("%02d") + info.min.format("%02d") + info.sec.format("%02d");
    }

    /**
     * Log system information at startup
     */
    function logSystemInfo() as Void {
        var stats = System.getSystemStats();
        var deviceSettings = System.getDeviceSettings();
        
        log(INFO, "System", "Battery: " + stats.battery + "%");
        log(INFO, "System", "Memory: " + stats.totalMemory + " bytes");
        log(INFO, "System", "Free Memory: " + stats.freeMemory + " bytes");
        log(INFO, "System", "Device: " + deviceSettings.partNumber);
        log(INFO, "System", "FW Version: " + deviceSettings.firmwareVersion);
    }

    /**
     * Main logging function
     * @param level - Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
     * @param tag - Category or component name
     * @param message - Log message
     */
    function log(level as LogLevel, tag as String, message as String) as Void {
        try {
            var timestamp = Time.now().value();
            var levelStr = getLevelString(level);
            var logEntry = timestamp + "|" + levelStr + "|" + tag + "|" + message;
            
            // Add to buffer
            logBuffer.add(logEntry);
            logCount++;
            
            // If buffer is full, flush to storage
            if (logBuffer.size() >= 10) {
                flushLogs();
            }
            
            // Also output to system for real-time debugging
            System.println("[" + levelStr + "] " + tag + ": " + message);
            
        } catch (e) {
            System.println("Logger error: " + e.getErrorMessage());
        }
    }

    /**
     * Convert log level to string
     */
    function getLevelString(level as LogLevel) as String {
        if (level == DEBUG) { return "DEBUG"; }
        else if (level == INFO) { return "INFO"; }
        else if (level == WARNING) { return "WARN"; }
        else if (level == ERROR) { return "ERROR"; }
        else if (level == CRITICAL) { return "CRIT"; }
        return "UNKNOWN";
    }

    /**
     * Flush buffered logs to persistent storage
     */
    function flushLogs() as Void {
        try {
            if (logBuffer.size() == 0) {
                return;
            }
            
            // Get existing logs
            var existingLogs = Storage.getValue(LOG_STORAGE_KEY);
            var allLogs = [];
            
            if (existingLogs != null && existingLogs instanceof Array) {
                allLogs = existingLogs as Array;
            }
            
            // Add new logs
            for (var i = 0; i < logBuffer.size(); i++) {
                allLogs.add(logBuffer[i]);
            }
            
            // Trim if too many entries
            while (allLogs.size() > MAX_LOG_ENTRIES) {
                allLogs = allLogs.slice(1, allLogs.size());
            }
            
            // Save to storage
            Storage.setValue(LOG_STORAGE_KEY, allLogs);
            
            // Clear buffer
            logBuffer = [];
            
        } catch (e) {
            System.println("Failed to flush logs: " + e.getErrorMessage());
        }
    }

    /**
     * Log an error with exception details
     */
    function logError(tag as String, message as String, exception as Exception) as Void {
        var errorMsg = message + " - " + exception.getErrorMessage();
        log(ERROR, tag, errorMsg);
        flushLogs(); // Immediately flush errors
    }

    /**
     * Log a crash with full context
     */
    function logCrash(tag as String, message as String, exception as Exception) as Void {
        try {
            var timestamp = Time.now().value();
            var stats = System.getSystemStats();
            
            var crashData = {
                "timestamp" => timestamp,
                "session" => currentSession,
                "tag" => tag,
                "message" => message,
                "error" => exception.getErrorMessage(),
                "battery" => stats.battery,
                "freeMemory" => stats.freeMemory,
                "totalMemory" => stats.totalMemory
            };
            
            // Get existing crash logs
            var crashLogs = Storage.getValue(CRASH_LOG_KEY);
            var allCrashes = [];
            
            if (crashLogs != null && crashLogs instanceof Array) {
                allCrashes = crashLogs as Array;
            }
            
            allCrashes.add(crashData);
            
            // Keep last 20 crashes
            while (allCrashes.size() > 20) {
                allCrashes = allCrashes.slice(1, allCrashes.size());
            }
            
            Storage.setValue(CRASH_LOG_KEY, allCrashes);
            
            // Also log normally
            log(CRITICAL, tag, "CRASH: " + message + " - " + exception.getErrorMessage());
            flushLogs();
            
        } catch (e) {
            System.println("Failed to log crash: " + e.getErrorMessage());
        }
    }

    /**
     * Log memory statistics
     */
    function logMemoryStats(tag as String) as Void {
        var stats = System.getSystemStats();
        var usedMemory = stats.totalMemory - stats.freeMemory;
        var memoryPercent = (usedMemory.toFloat() / stats.totalMemory.toFloat() * 100).toNumber();
        
        log(INFO, tag, "Memory: " + usedMemory + "/" + stats.totalMemory + 
            " (" + memoryPercent + "% used)");
    }

    /**
     * Log activity data for debugging
     */
    function logActivityInfo(tag as String, info as Lang.Object) as Void {
        if (info == null) {
            log(WARNING, tag, "Activity info is null");
            return;
        }
        
        var activityInfo = info;
        var msg = "Activity - ";
        
        // Safely access properties
        try {
            if (activityInfo has :currentCadence && activityInfo.currentCadence != null) {
                msg += "Cadence:" + activityInfo.currentCadence + " ";
            }
            if (activityInfo has :currentHeartRate && activityInfo.currentHeartRate != null) {
                msg += "HR:" + activityInfo.currentHeartRate + " ";
            }
            if (activityInfo has :elapsedDistance && activityInfo.elapsedDistance != null) {
                msg += "Dist:" + (activityInfo.elapsedDistance / 100000.0).format("%.2f") + "km ";
            }
            if (activityInfo has :timerTime && activityInfo.timerTime != null) {
                msg += "Time:" + (activityInfo.timerTime / 1000) + "s";
            }
        } catch (e) {
            msg += "Error reading activity info";
        }
        
        log(DEBUG, tag, msg);
    }

    /**
     * Get all logs as formatted string for display or export
     */
    function getLogsAsString() as String {
        flushLogs(); // Ensure all logs are saved
        
        var logs = Storage.getValue(LOG_STORAGE_KEY);
        if (logs == null || !(logs instanceof Array)) {
            return "No logs available";
        }
        
        var result = "=== APP LOGS ===\n";
        var logArray = logs as Array;
        
        for (var i = 0; i < logArray.size(); i++) {
            result += logArray[i] + "\n";
        }
        
        return result;
    }

    /**
     * Get crash logs as formatted string
     */
    function getCrashLogsAsString() as String {
        var crashes = Storage.getValue(CRASH_LOG_KEY);
        if (crashes == null || !(crashes instanceof Array)) {
            return "No crash logs available";
        }
        
        var result = "=== CRASH LOGS ===\n";
        var crashArray = crashes as Array;
        
        for (var i = 0; i < crashArray.size(); i++) {
            var crash = crashArray[i];
            if (crash instanceof Dictionary) {
                var crashDict = crash as Dictionary;
                result += "Crash " + (i + 1) + ":\n";
                result += "  Time: " + crashDict["timestamp"] + "\n";
                result += "  Session: " + crashDict["session"] + "\n";
                result += "  Tag: " + crashDict["tag"] + "\n";
                result += "  Message: " + crashDict["message"] + "\n";
                result += "  Error: " + crashDict["error"] + "\n";
                result += "  Battery: " + crashDict["battery"] + "%\n";
                result += "  Memory: " + crashDict["freeMemory"] + "/" + 
                         crashDict["totalMemory"] + "\n\n";
            }
        }
        
        return result;
    }

    /**
     * Clear all logs
     */
    function clearLogs() as Void {
        Storage.deleteValue(LOG_STORAGE_KEY);
        Storage.deleteValue(CRASH_LOG_KEY);
        logBuffer = [];
        logCount = 0;
        log(INFO, "Logger", "Logs cleared");
    }

    /**
     * Shutdown logger and ensure all logs are saved
     */
    function shutdown() as Void {
        log(INFO, "Logger", "Session ended: " + currentSession);
        flushLogs();
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool isPluggedIn: isCharging || chargeState == UPowerDeviceState.PendingCharge || chargeState == UPowerDeviceState.FullyCharged
    property real percentage: UPower.displayDevice.percentage
    
    // Time properties (in seconds)
    property real timeToEmpty: UPower.displayDevice.timeToEmpty || 0
    property real timeToFull: UPower.displayDevice.timeToFull || 0
    
    // Helper function to format time
    function formatTime(seconds) {
        if (seconds <= 0) return "Unknown";
        
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        
        if (hours > 0) {
            return hours + "h " + minutes + "m";
        } else {
            return minutes + "m";
        }
    }
    
    // Get appropriate time string based on charging state
    property string timeString: {
        if (!available) return "N/A";
        
        if (isCharging && timeToFull > 0) {
            return formatTime(timeToFull) + " to full";
        } else if (!isCharging && timeToEmpty > 0) {
            return formatTime(timeToEmpty) + " remaining";
        } else {
            return "Time unknown";
        }
    }
    

}
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property real brightness: 0.0
    property real maxBrightness: 100.0
    property bool available: false
    
    signal brightnessUpdated()
    
    // Monitor brightness file
    FileView {
        id: brightnessFile
        path: "/sys/class/backlight/intel_backlight/brightness"
        
        onLoaded: {
            const value = parseFloat(text());
            if (!isNaN(value) && value !== root.brightness) {
                root.brightness = value;
                root.available = true;
                root.brightnessUpdated();
            }
        }
    }
    
    // Monitor max brightness file
    FileView {
        id: maxBrightnessFile
        path: "/sys/class/backlight/intel_backlight/max_brightness"
        
        onLoaded: {
            const value = parseFloat(text());
            if (!isNaN(value)) {
                root.maxBrightness = value;
            }
        }
    }
    
    // Timer to periodically check for brightness changes
    Timer {
        id: brightnessTimer
        interval: 100  // Check every 100ms for responsive updates
        running: true
        repeat: true
        onTriggered: {
            brightnessFile.reload();
        }
    }
    
    Component.onCompleted: {
        // Load initial values
        maxBrightnessFile.reload();
        brightnessFile.reload();
    }
    
    function setBrightness(value) {
        const clampedValue = Math.max(0, Math.min(value, root.maxBrightness));
        
        const setBrightnessProcess = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["brightnessctl", "set", "${clampedValue}"]
                running: true
            }
        `, root);
    }
    
    function setBrightnessPercent(percent) {
        const clampedPercent = Math.max(0, Math.min(percent, 100));
        
        const setBrightnessProcess = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["brightnessctl", "set", "${clampedPercent}%"]
                running: true
            }
        `, root);
    }
    
    // Helper to get brightness as percentage
    property real brightnessPercent: maxBrightness > 0 ? (brightness / maxBrightness) * 100 : 0
}

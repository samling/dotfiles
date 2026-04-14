pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.common

Singleton {
    id: root

    property real brightness: 0.0
    property real maxBrightness: 100.0
    property bool available: false
    property string backlightPath: ""

    signal brightnessUpdated()

    // Discover the backlight device via brightnessctl
    Process {
        id: detectProcess
        command: ["brightnessctl", "-m", "-c", "backlight"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const name = data.split(",")[0];
                if (name) {
                    root.backlightPath = "/sys/class/backlight/" + name;
                    brightnessFile.path = root.backlightPath + "/brightness";
                    maxBrightnessFile.path = root.backlightPath + "/max_brightness";
                    maxBrightnessFile.reload();
                    brightnessFile.reload();
                }
            }
        }
    }

    // Monitor brightness file
    FileView {
        id: brightnessFile
        path: ""

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
        path: ""

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
        interval: Config.brightnessCheckInterval
        running: root.backlightPath !== ""
        repeat: true
        onTriggered: {
            brightnessFile.reload();
        }
    }

    // Process for setting brightness values
    Process {
        id: setBrightnessProcess
        property string targetValue: ""

        command: ["brightnessctl", "set", targetValue]
    }
    
    function setBrightness(value) {
        const clampedValue = Math.max(0, Math.min(value, root.maxBrightness));
        setBrightnessProcess.targetValue = clampedValue.toString();
        setBrightnessProcess.running = true;
    }
    
    function setBrightnessPercent(percent) {
        const clampedPercent = Math.max(0, Math.min(percent, 100));
        setBrightnessProcess.targetValue = clampedPercent + "%";
        setBrightnessProcess.running = true;
    }
    
    // Helper to get brightness as percentage
    property real brightnessPercent: maxBrightness > 0 ? (brightness / maxBrightness) * 100 : 0
}

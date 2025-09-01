pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: config
    
    // Color palette system
    property var paletteData: ({})
    readonly property var palette: paletteData.colors || {}
    readonly property var semanticColors: paletteData.semantic || {}
    readonly property bool paletteLoaded: !!(paletteData.colors && paletteData.semantic)
    
    property bool paletteInitialized: false
    
    property FileView paletteFile: FileView {
        path: Qt.resolvedUrl("palette.json")
        watchChanges: true
        
        onLoaded: {
            try {
                config.paletteData = JSON.parse(text())
                if (config.paletteInitialized) {
                    console.log("[Config] *** FILE CHANGED *** Palette reloaded:", config.paletteData.name || "Unknown")
                } else {
                    console.log("[Config] Initial palette load:", config.paletteData.name || "Unknown")
                    config.paletteInitialized = true
                }
            } catch (e) {
                console.error("[Config] Failed to parse palette.json:", e)
                config.paletteData = getDefaultPalette()
            }
        }
        
        onFileChanged: {
            console.log("[Config] File change detected, reloading...")
            reload()
        }
        
        onLoadFailed: {
            console.error("[Config] Failed to load palette.json, using defaults")
            config.paletteData = getDefaultPalette()
        }
    }
    
    function getDefaultPalette() {
        return {
            "name": "Fallback Theme",
            "colors": {
                "primary": {"blue": "#89b4fa", "green": "#a6e3a1", "red": "#f38ba8", "white": "#ffffff"},
                "text": {"primary": "#cdd6f4", "light": "#e2e8f0"},
                "background": {"primary": "#1e1e2e", "secondary": "#2d3748", "bar": "#1e1e2e"}
            }
        }
    }
    
    function getColor(path) {
        const parts = path.split('.')
        
        // First try semantic colors (for component roles like "workspace.active")
        if (paletteData.semantic) {
            let current = paletteData.semantic
            let found = true
            
            for (let part of parts) {
                if (current && typeof current === 'object' && part in current) {
                    current = current[part]
                } else {
                    found = false
                    break
                }
            }
            
            if (found) {
                // If it's a reference to another color (like "primary.blue"), resolve it
                if (typeof current === 'string') {
                    const refParts = current.split('.')
                    let refCurrent = paletteData.colors
                    
                    for (let refPart of refParts) {
                        if (refCurrent && typeof refCurrent === 'object' && refPart in refCurrent) {
                            refCurrent = refCurrent[refPart]
                        } else {
                            console.warn("[Config] Color reference not found:", current, "for", path)
                            return "#6c7086" // Fallback gray
                        }
                    }
                    return refCurrent
                }
                return current
            }
        }
        
        // Fallback to direct colors (for direct color paths like "primary.blue")
        if (paletteData.colors) {
            let current = paletteData.colors
            
            for (let part of parts) {
                if (current && typeof current === 'object' && part in current) {
                    current = current[part]
                } else {
                    console.warn("[Config] Color not found:", path)
                    return "#6c7086" // Fallback gray
                }
            }
            
            return current
        }
        
        console.error("[Config] No palette data available for:", path)
        return "#6c7086" // Fallback gray
    }

    // Bar dimensions
    readonly property int barHeight: 40
    readonly property int barRadius: 1
    readonly property string barBackgroundColor: getColor("background.bar")

    // Bar layout spacing
    readonly property int barContentLeftMargin: 8
    readonly property int barContentRightMargin: 8
    readonly property int barContentSpacing: 4

    // BarGroup styling
    readonly property int groupBackgroundMarginLeft: 4
    readonly property int groupBackgroundMarginRight: 4
    readonly property int groupBorderWidth: 1
    readonly property int groupRadius: 4
    readonly property string groupBorderColor: "transparent"
    readonly property int groupColumnSpacing: 4
    readonly property int groupRowSpacing: 12
    readonly property int groupImplicitWidthPadding: 8

    // Workspace indicators
    readonly property int workspaceSpacing: 6
    readonly property int workspaceWidth: 18
    readonly property int workspaceHeight: 15
    readonly property int workspaceRadius: 4
    readonly property int workspaceFontSize: 12
    readonly property int workspaceBorderWidth: 2
    readonly property string workspaceActiveColor: getColor("workspace.active")
    readonly property string workspaceActiveBrightColor: getColor("workspace.active")
    readonly property string workspaceOccupiedColor: getColor("workspace.occupied")
    readonly property string workspaceEmptyColor: getColor("workspace.empty")
    readonly property string workspaceActiveBorderColor: getColor("workspace.active")
    readonly property string workspaceActiveTextColor: getColor("text.white")
    readonly property string workspaceOccupiedTextColor: getColor("text.light")
    readonly property string workspaceEmptyTextColor: getColor("text.muted")

    // Battery indicator
    readonly property int batteryFontSize: 12
    readonly property int batterySpacing: 4
    readonly property string batteryTextColor: getColor("text.white")
    
    // Battery gauge (circular)
    readonly property int batteryGaugeOffset: 14  // Subtracted from barHeight for gauge size
    readonly property int batteryGaugeLineWidth: 2
    readonly property real batteryGaugeBackgroundOpacity: 0.3
    readonly property real batteryGaugeFontSizeMultiplier: 1
    
    // Battery threshold values (as percentages 0.0-1.0)
    readonly property real batteryCriticalThreshold: 0.15  // 15%
    readonly property real batteryLowThreshold: 0.30       // 30%
    readonly property real batteryMediumThreshold: 0.50    // 50%
    
    // Battery gauge colors
    readonly property string batteryUnavailableColor: getColor("battery.unavailable")
    readonly property string batteryChargingColor: getColor("battery.charging")
    readonly property string batteryHighColor: getColor("battery.high")
    readonly property string batteryMediumColor: getColor("battery.medium")
    readonly property string batteryLowColor: getColor("battery.low")
    readonly property string batteryCriticalColor: getColor("battery.critical")

    // Clock widget
    readonly property string clockTextColor: getColor("text.white")
    readonly property int clockFontSize: 14

    // Animation durations
    readonly property int colorAnimationDuration: 200
    
    // Notification system colors
    readonly property string notificationBackgroundColor: getColor("notification.background")
    readonly property string notificationBorderColor: getColor("notification.border")
    readonly property string notificationActiveColor: getColor("notification.active")
    readonly property string notificationInactiveColor: getColor("notification.inactive")
    readonly property string notificationActiveAccentColor: getColor("notification.accent")
    readonly property string notificationTextPrimaryColor: getColor("text.primary")
    readonly property string notificationTextSecondaryColor: getColor("text.secondary")
    readonly property string notificationTextTertiaryColor: getColor("text.tertiary")
    readonly property string notificationCloseColor: getColor("notification.close")
    readonly property string notificationClosePressedColor: getColor("notification.closePressed")
    readonly property string notificationButtonColor: getColor("interactive.default")
    readonly property string notificationButtonPressedColor: getColor("interactive.pressed")
    
    // OSD (On-Screen Display) colors
    readonly property string osdBackgroundColor: getColor("osd.background")
    readonly property string osdTrackColor: getColor("osd.track")
    readonly property string osdFillColor: getColor("osd.fill")
    
    // Tooltip colors
    readonly property string tooltipBackgroundColor: getColor("tooltip.background")
    readonly property string tooltipBorderColor: getColor("tooltip.border")
    readonly property string tooltipShadowColor: getColor("tooltip.shadow")
    readonly property string tooltipTextColor: getColor("tooltip.text")
    readonly property real tooltipShadowOpacity: 0.3
    
    // Common sizing and timing
    readonly property int brightnessCheckInterval: 100  // milliseconds
    readonly property int clockUpdateInterval: 1000     // milliseconds
}

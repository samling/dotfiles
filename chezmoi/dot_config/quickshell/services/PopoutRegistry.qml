pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var surfaces: [
        {
            id: "info-panel",
            label: "Info Panel",
            oneOpenGroup: "main",
            openAction: "info-panel.open",
            closeAction: "info-panel.close",
            toggleAction: "info-panel.toggle"
        },
        {
            id: "settings",
            label: "Settings",
            oneOpenGroup: "main",
            openAction: "settings.open",
            closeAction: "settings.close",
            toggleAction: "settings.toggle"
        },
        {
            id: "wallpaper-picker",
            label: "Wallpaper Picker",
            oneOpenGroup: "main",
            openAction: "wallpaper-picker.open",
            closeAction: "wallpaper-picker.close",
            toggleAction: "wallpaper-picker.toggle"
        },
        {
            id: "wifi",
            label: "WiFi",
            parentSurface: "info-panel",
            oneOpenGroup: "main",
            openAction: "wifi.open"
        },
        {
            id: "bluetooth",
            label: "Bluetooth",
            parentSurface: "info-panel",
            oneOpenGroup: "main",
            openAction: "bluetooth.open"
        },
        {
            id: "power",
            label: "Power",
            oneOpenGroup: "main",
            openAction: "power.open",
            closeAction: "power.close",
            toggleAction: "power.toggle"
        }
    ]

    readonly property var actions: [
        { id: "info-panel.open", surfaceId: "info-panel", operation: "open" },
        { id: "info-panel.close", surfaceId: "info-panel", operation: "close" },
        { id: "info-panel.toggle", surfaceId: "info-panel", operation: "toggle" },
        { id: "settings.open", surfaceId: "settings", operation: "open" },
        { id: "settings.close", surfaceId: "settings", operation: "close" },
        { id: "settings.toggle", surfaceId: "settings", operation: "toggle" },
        { id: "wallpaper-picker.open", surfaceId: "wallpaper-picker", operation: "open" },
        { id: "wallpaper-picker.close", surfaceId: "wallpaper-picker", operation: "close" },
        { id: "wallpaper-picker.toggle", surfaceId: "wallpaper-picker", operation: "toggle" },
        { id: "wifi.open", surfaceId: "wifi", operation: "open" },
        { id: "bluetooth.open", surfaceId: "bluetooth", operation: "open" },
        { id: "power.open", surfaceId: "power", operation: "open" },
        { id: "power.close", surfaceId: "power", operation: "close" },
        { id: "power.toggle", surfaceId: "power", operation: "toggle" },
        { id: "close-all", operation: "close-all" }
    ]

    function surface(id) {
        return surfaces.find((item) => item.id === id) || null
    }

    function action(actionId) {
        return actions.find((item) => item.id === actionId) || null
    }
}

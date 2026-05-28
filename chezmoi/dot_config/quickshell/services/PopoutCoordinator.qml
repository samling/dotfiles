pragma Singleton

import QtQuick
import Quickshell
import qs.common

Singleton {
    id: root

    property bool infoPanelOpen: GlobalStates.sidebarRightOpen
    property bool wallpaperPickerOpen: GlobalStates.wallpaperPickerOpen
    property bool settingsOpen: false
    property bool powerOpen: false
    property string infoPanelSubPanel: ""

    function dispatch(actionId) {
        const item = PopoutRegistry.action(actionId)
        if (!item) return false

        if (item.operation === "close-all") closeAll()
        else if (item.surfaceId === "info-panel") dispatchInfoPanel(item.operation)
        else if (item.surfaceId === "settings") dispatchSettings(item.operation)
        else if (item.surfaceId === "wallpaper-picker") dispatchWallpaperPicker(item.operation)
        else if (item.surfaceId === "wifi" && item.operation === "open") openInfoPanelSubPanel("wifi")
        else if (item.surfaceId === "bluetooth" && item.operation === "open") openInfoPanelSubPanel("bluetooth")
        else if (item.surfaceId === "power") dispatchPower(item.operation)
        else return false

        return true
    }

    function closeAll() {
        closeInfoPanel()
        closeWallpaperPicker()
        closeSettings()
        closePower()
    }

    function closeOneOpenGroup(surfaceId) {
        const item = PopoutRegistry.surface(surfaceId)
        if (!item || item.oneOpenGroup !== "main" || !SettingsStore.value("popouts.oneOpenGroup")) return

        if (surfaceId !== "info-panel") closeInfoPanel()
        if (surfaceId !== "wallpaper-picker") closeWallpaperPicker()
        if (surfaceId !== "settings") closeSettings()
        if (surfaceId !== "power") closePower()
    }

    function dispatchInfoPanel(operation) {
        if (operation === "open") openInfoPanel()
        else if (operation === "close") closeInfoPanel()
        else if (operation === "toggle") toggleInfoPanel()
    }

    function dispatchSettings(operation) {
        if (operation === "open") openSettings()
        else if (operation === "close") closeSettings()
        else if (operation === "toggle") toggleSettings()
    }

    function dispatchWallpaperPicker(operation) {
        if (operation === "open") openWallpaperPicker()
        else if (operation === "close") closeWallpaperPicker()
        else if (operation === "toggle") toggleWallpaperPicker()
    }

    function dispatchPower(operation) {
        if (operation === "open") openPower()
        else if (operation === "close") closePower()
        else if (operation === "toggle") togglePower()
    }

    function openInfoPanel() {
        closeOneOpenGroup("info-panel")
        GlobalStates.sidebarRightOpen = true
    }

    function closeInfoPanel() {
        GlobalStates.sidebarRightOpen = false
        infoPanelSubPanel = ""
    }

    function toggleInfoPanel() {
        if (GlobalStates.sidebarRightOpen) closeInfoPanel()
        else openInfoPanel()
    }

    function setInfoPanelSubPanel(name) {
        infoPanelSubPanel = name || ""
    }

    function openInfoPanelSubPanel(name) {
        openInfoPanel()
        setInfoPanelSubPanel(name)
    }

    function openWallpaperPicker() {
        closeOneOpenGroup("wallpaper-picker")
        GlobalStates.wallpaperPickerOpen = true
    }

    function closeWallpaperPicker() {
        GlobalStates.wallpaperPickerOpen = false
    }

    function toggleWallpaperPicker() {
        if (GlobalStates.wallpaperPickerOpen) closeWallpaperPicker()
        else openWallpaperPicker()
    }

    function openSettings() {
        closeOneOpenGroup("settings")
        settingsOpen = true
    }

    function closeSettings() {
        settingsOpen = false
    }

    function toggleSettings() {
        if (settingsOpen) closeSettings()
        else openSettings()
    }

    function openPower() {
        closeOneOpenGroup("power")
        powerOpen = true
    }

    function closePower() {
        powerOpen = false
    }

    function togglePower() {
        if (powerOpen) closePower()
        else openPower()
    }
}

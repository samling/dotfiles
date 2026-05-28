pragma Singleton

import QtQuick
import Quickshell
import qs.common

Singleton {
    id: root

    property bool infoPanelOpen: GlobalStates.sidebarRightOpen
    property bool wallpaperPickerOpen: GlobalStates.wallpaperPickerOpen
    property bool settingsOpen: false
    property string infoPanelSubPanel: ""

    function closeAll() {
        closeInfoPanel()
        closeWallpaperPicker()
        closeSettings()
    }

    function openInfoPanel() {
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
        closeInfoPanel()
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
        closeInfoPanel()
        closeWallpaperPicker()
        settingsOpen = true
    }

    function closeSettings() {
        settingsOpen = false
    }

    function toggleSettings() {
        if (settingsOpen) closeSettings()
        else openSettings()
    }
}

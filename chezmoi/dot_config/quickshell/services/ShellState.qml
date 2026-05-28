pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/quickshell"
    readonly property string stateFilePath: stateDir + "/shell-state.json"

    property string lastSettingsPage: "bar"
    property string wallpaperSortMode: "name"
    property string wallpaperSearchText: ""
    property double notificationLastSeenTime: 0
    property bool _loading: false

    Timer {
        id: saveTimer
        interval: 250
        repeat: false
        onTriggered: shellStateFile.setText(JSON.stringify(root.toJSON(), null, 2) + "\n")
    }

    FileView {
        id: shellStateFile
        path: root.stateFilePath
        watchChanges: true
        onLoaded: root.loadText(text())
        onLoadFailed: shellStateFile.setText(JSON.stringify(root.toJSON(), null, 2) + "\n")
    }

    onLastSettingsPageChanged: scheduleSave()
    onWallpaperSortModeChanged: scheduleSave()
    onWallpaperSearchTextChanged: scheduleSave()
    onNotificationLastSeenTimeChanged: scheduleSave()

    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", stateDir])

    function scheduleSave() {
        if (!_loading) saveTimer.restart()
    }

    function toJSON() {
        return {
            lastSettingsPage: lastSettingsPage,
            wallpaperSortMode: wallpaperSortMode,
            wallpaperSearchText: wallpaperSearchText,
            notificationLastSeenTime: notificationLastSeenTime,
        }
    }

    function loadText(raw) {
        let parsed = ({})
        try {
            parsed = raw && raw.trim() ? JSON.parse(raw) : ({})
        } catch (_) {
            parsed = ({})
        }

        _loading = true
        lastSettingsPage = typeof parsed.lastSettingsPage === "string" ? parsed.lastSettingsPage : "bar"
        wallpaperSortMode = typeof parsed.wallpaperSortMode === "string" ? parsed.wallpaperSortMode : "name"
        wallpaperSearchText = typeof parsed.wallpaperSearchText === "string" ? parsed.wallpaperSearchText : ""
        notificationLastSeenTime = typeof parsed.notificationLastSeenTime === "number" ? parsed.notificationLastSeenTime : 0
        _loading = false
    }
}

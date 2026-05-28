pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var log: Log.scoped("SettingsStore")
    property string activeSettingsPath: Quickshell.env("QUICKSHELL_SETTINGS_FILE") || Qt.resolvedUrl("../common/config.json")
    property var overrides: ({})
    property var effectiveSettings: SettingsRegistry.mergeDefaults(overrides)
    property bool loaded: false
    property bool _saving: false

    Timer {
        id: saveTimer
        interval: 250
        repeat: false
        onTriggered: root.save()
    }

    FileView {
        id: settingsFile
        path: root.activeSettingsPath
        watchChanges: true

        onLoaded: root.loadText(text())

        onFileChanged: {
            if (root._saving) {
                root._saving = false
                return
            }
            reload()
        }

        onLoadFailed: {
            root.overrides = ({})
            root.effectiveSettings = SettingsRegistry.mergeDefaults(root.overrides)
            root.loaded = true
        }
    }

    function loadText(raw) {
        try {
            const parsed = raw && raw.trim() ? JSON.parse(raw) : ({})
            root.overrides = sanitizeOverrides(parsed)
        } catch (e) {
            root.log.warn("Failed to parse settings file", e)
            root.overrides = ({})
        }
        root.effectiveSettings = SettingsRegistry.mergeDefaults(root.overrides)
        root.loaded = true
    }

    function value(path) {
        const override = SettingsRegistry.getPath(overrides, path)
        return override !== undefined ? override : SettingsRegistry.defaultValue(path)
    }

    function setValue(path, value) {
        if (!SettingsRegistry.validate(path, value)) {
            root.log.warn("Ignoring invalid setting", path, JSON.stringify(value))
            return false
        }

        const next = SettingsRegistry.clone(overrides)
        const defaultValue = SettingsRegistry.defaultValue(path)
        if (SettingsRegistry.equal(value, defaultValue)) SettingsRegistry.unsetPath(next, path)
        else SettingsRegistry.setPath(next, path, SettingsRegistry.clone(value))

        root.overrides = next
        root.effectiveSettings = SettingsRegistry.mergeDefaults(root.overrides)
        saveTimer.restart()
        return true
    }

    function resetValue(path) {
        const next = SettingsRegistry.clone(overrides)
        SettingsRegistry.unsetPath(next, path)
        root.overrides = next
        root.effectiveSettings = SettingsRegistry.mergeDefaults(root.overrides)
        saveTimer.restart()
    }

    function exportOverrides() {
        return SettingsRegistry.clone(overrides)
    }

    function save() {
        root._saving = true
        settingsFile.setText(JSON.stringify(exportOverrides(), null, 2) + "\n")
    }

    function sanitizeOverrides(input) {
        const out = {}
        SettingsRegistry.fields.forEach((field) => {
            const override = SettingsRegistry.getPath(input, field.path)
            if (override === undefined) return
            if (!SettingsRegistry.validate(field.path, override)) return
            if (SettingsRegistry.equal(override, field.defaultValue)) return
            SettingsRegistry.setPath(out, field.path, SettingsRegistry.clone(override))
        })
        return out
    }
}

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var fields: [
        { path: "updates.criticalPackages", label: "Critical packages", type: "list", defaultValue: [], page: "updates" },
        { path: "updates.warningPackages", label: "Warning packages", type: "list", defaultValue: [], page: "updates" },
        { path: "bar.primaryMonitor", label: "Primary monitor", type: "string", defaultValue: "", page: "bar" },
        { path: "bar.showPowerProfile", label: "Show power profile", type: "bool", defaultValue: true, page: "bar" },
        { path: "bar.showGpu", label: "Show GPU", type: "bool", defaultValue: true, page: "bar" },
        { path: "wallpaper.directory", label: "Wallpaper directory", type: "path", defaultValue: "", page: "wallpaper" },
        { path: "notifications.maxHistoryCount", label: "Notification history count", type: "int", defaultValue: 100, min: 0, page: "notifications" },
        { path: "notifications.maxHistoryAgeDays", label: "Notification history age", type: "int", defaultValue: 14, min: 0, page: "notifications" },
        { path: "notifications.dedupe", label: "Dedupe notifications", type: "bool", defaultValue: true, page: "notifications" },
        { path: "notifications.rules", label: "Notification rules", type: "list", defaultValue: [], page: "notifications" },
        { path: "systemStats.fastPollInterval", label: "Fast poll interval", type: "int", defaultValue: 5000, min: 1000, page: "system" },
        { path: "systemStats.diskPollInterval", label: "Disk poll interval", type: "int", defaultValue: 30000, min: 5000, page: "system" },
        { path: "systemStats.diskMountPoint", label: "Disk mount point", type: "string", defaultValue: "/", page: "system" },
        { path: "ui.fontScale", label: "Font scale", type: "real", defaultValue: 1.0, min: 0.75, max: 1.5, page: "appearance" },
        { path: "ui.spacingScale", label: "Spacing scale", type: "real", defaultValue: 1.0, min: 0.75, max: 1.5, page: "appearance" },
        { path: "ui.radiusScale", label: "Radius scale", type: "real", defaultValue: 1.0, min: 0.75, max: 1.5, page: "appearance" },
        { path: "popouts.oneOpenGroup", label: "One popout at a time", type: "bool", defaultValue: true, page: "popouts" },
    ]

    readonly property var pages: [
        { id: "bar", label: "Bar" },
        { id: "appearance", label: "Appearance" },
        { id: "notifications", label: "Notifications" },
        { id: "wallpaper", label: "Wallpaper" },
        { id: "system", label: "System" },
        { id: "popouts", label: "Popouts" },
        { id: "updates", label: "Updates" },
    ]

    readonly property var defaultsObject: buildDefaultsObject()

    function field(path) {
        return fields.find((item) => item.path === path) || null
    }

    function fieldsForPage(pageId) {
        return fields.filter((item) => item.page === pageId)
    }

    function defaultValue(path) {
        const item = field(path)
        return item ? clone(item.defaultValue) : undefined
    }

    function validate(path, value) {
        const item = field(path)
        if (!item) return false
        if (value === undefined) return false

        if (item.type === "bool") return typeof value === "boolean"
        if (item.type === "int") return typeof value === "number" && Math.floor(value) === value && inRange(item, value)
        if (item.type === "real") return typeof value === "number" && inRange(item, value)
        if (item.type === "string" || item.type === "path" || item.type === "color") return typeof value === "string"
        if (item.type === "enum") return item.options && item.options.indexOf(value) !== -1
        if (item.type === "list") return Array.isArray(value)
        return true
    }

    function inRange(item, value) {
        if (item.min !== undefined && value < item.min) return false
        if (item.max !== undefined && value > item.max) return false
        return true
    }

    function buildDefaultsObject() {
        const out = {}
        fields.forEach((item) => setPath(out, item.path, clone(item.defaultValue)))
        return out
    }

    function setPath(object, path, value) {
        const parts = path.split(".")
        let cursor = object
        for (let i = 0; i < parts.length - 1; i++) {
            if (!cursor[parts[i]] || typeof cursor[parts[i]] !== "object" || Array.isArray(cursor[parts[i]])) cursor[parts[i]] = {}
            cursor = cursor[parts[i]]
        }
        cursor[parts[parts.length - 1]] = value
    }

    function getPath(object, path) {
        const parts = path.split(".")
        let cursor = object
        for (let i = 0; i < parts.length; i++) {
            if (cursor === null || cursor === undefined) return undefined
            cursor = cursor[parts[i]]
        }
        return cursor
    }

    function unsetPath(object, path) {
        const parts = path.split(".")
        let cursor = object
        for (let i = 0; i < parts.length - 1; i++) {
            cursor = cursor?.[parts[i]]
            if (!cursor) return
        }
        delete cursor[parts[parts.length - 1]]
        pruneEmpty(object)
    }

    function pruneEmpty(object) {
        Object.keys(object).forEach((key) => {
            const value = object[key]
            if (value && typeof value === "object" && !Array.isArray(value)) {
                pruneEmpty(value)
                if (Object.keys(value).length === 0) delete object[key]
            }
        })
    }

    function clone(value) {
        if (value === undefined) return undefined
        return JSON.parse(JSON.stringify(value))
    }

    function equal(a, b) {
        return JSON.stringify(a) === JSON.stringify(b)
    }

    function mergeDefaults(overrides) {
        return deepMerge(defaultsObject, overrides || ({}))
    }

    function deepMerge(base, overlay) {
        if (overlay === null || overlay === undefined) return clone(base)
        if (typeof base !== "object" || base === null || Array.isArray(base)) return clone(overlay)
        if (typeof overlay !== "object" || Array.isArray(overlay)) return clone(overlay)

        const out = clone(base)
        for (const key in overlay) out[key] = deepMerge(base[key], overlay[key])
        return out
    }
}

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Local registry only: every component path is a checked-in bar component.
    readonly property var widgets: [
        {
            id: "power",
            label: "Power",
            componentPath: "../bar/PowerMenu.qml",
            defaultSection: "left",
            defaultOrder: 0,
            defaultVisible: true,
            configurableFields: []
        },
        {
            id: "workspaces",
            label: "Workspaces",
            componentPath: "../bar/Workspaces.qml",
            defaultSection: "left",
            defaultOrder: 1,
            defaultVisible: true,
            configurableFields: []
        },
        {
            id: "clock",
            label: "Clock",
            componentPath: "../bar/ClockWidget.qml",
            defaultSection: "center",
            defaultOrder: 0,
            defaultVisible: true,
            configurableFields: []
        },
        {
            id: "network-system",
            label: "Network and system",
            componentPath: "../bar/NetworkSystemGroup.qml",
            defaultSection: "right",
            defaultOrder: 2,
            defaultVisible: true,
            configurableFields: ["systemStats.fastPollInterval", "systemStats.diskPollInterval", "systemStats.diskMountPoint"]
        },
        {
            id: "tray",
            label: "System tray",
            componentPath: "../bar/SysTray.qml",
            defaultSection: "right",
            defaultOrder: 0,
            defaultVisible: true,
            configurableFields: []
        },
        {
            id: "tailscale",
            label: "Tailscale",
            componentPath: "../bar/TailscaleIndicator.qml",
            defaultSection: "right",
            defaultOrder: 1,
            defaultVisible: true,
            configurableFields: []
        },
        {
            id: "battery",
            label: "Battery",
            componentPath: "../bar/BatteryIndicator.qml",
            defaultSection: "right",
            defaultOrder: 3,
            defaultVisible: true,
            configurableFields: []
        },
        {
            id: "volume",
            label: "Volume",
            componentPath: "../bar/VolumeIndicator.qml",
            defaultSection: "right",
            defaultOrder: 4,
            defaultVisible: true,
            configurableFields: []
        },
        {
            id: "updates",
            label: "Updates",
            componentPath: "../bar/Updates.qml",
            defaultSection: "right",
            defaultOrder: 5,
            defaultVisible: true,
            configurableFields: ["updates.criticalPackages", "updates.warningPackages"]
        },
        {
            id: "notifications",
            label: "Notifications",
            componentPath: "../bar/NotificationButton.qml",
            defaultSection: "right",
            defaultOrder: 6,
            defaultVisible: true,
            configurableFields: ["notifications.maxHistoryCount", "notifications.maxHistoryAgeDays", "notifications.dedupe", "notifications.rules"]
        }
    ]

    readonly property var sections: ["left", "center", "right"]

    function widget(id) {
        return widgets.find((item) => item.id === id) || null
    }

    function defaultLayout() {
        const out = { left: [], center: [], right: [] }
        widgets.forEach((item) => {
            if (!item.defaultVisible) return
            out[item.defaultSection].push(item.id)
        })
        sections.forEach((section) => out[section].sort((a, b) => widget(a).defaultOrder - widget(b).defaultOrder))
        return out
    }

    function widgetsForSection(section, layout) {
        const ids = (layout && Array.isArray(layout[section])) ? layout[section] : defaultLayout()[section]
        return ids.map((id) => widget(id)).filter((item) => item !== null && item.defaultVisible)
    }
}

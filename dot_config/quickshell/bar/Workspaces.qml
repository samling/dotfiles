pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

import qs.common

Item {
    id: root
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen ?? null)
    readonly property bool hasMultipleMonitors: Quickshell.screens.length > 1
    property list<bool> workspaceOccupied: []
    property list<bool> secondaryWorkspaceOccupied: []

    // Theme colors
    property color activeColor: Config.getColor("workspace.active")
    property color activeSecondaryColor: Config.getColor("workspace.activeSecondary")
    property color occupiedColor: Config.getColor("workspace.occupied")
    property color emptyColor: Config.getColor("workspace.empty")
    property color dividerColor: Config.getColor("workspace.divider")

    // Get active workspace IDs from all monitors
    readonly property var activeWorkspaceIds: {
        let ids = []
        for (let i = 0; i < Hyprland.monitors.values.length; i++) {
            let mon = Hyprland.monitors.values[i]
            if (mon && mon.activeWorkspace) {
                ids.push(mon.activeWorkspace.id)
            }
        }
        return ids
    }

    // Determine which monitor owns a workspace (for coloring)
    function getActiveMonitorIndex(workspaceId) {
        for (let i = 0; i < Hyprland.monitors.values.length; i++) {
            let mon = Hyprland.monitors.values[i]
            if (mon && mon.activeWorkspace && mon.activeWorkspace.id === workspaceId) {
                return i
            }
        }
        return -1
    }

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: workspaceRow.implicitHeight

    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 6

        // Primary workspaces (1-10)
        Repeater {
            model: 10

            Rectangle {
                id: workspaceIndicator
                required property int index
                readonly property int workspaceId: workspaceIndicator.index + 1
                readonly property int activeMonitorIdx: root.getActiveMonitorIndex(workspaceIndicator.workspaceId)
                readonly property bool isActive: workspaceIndicator.activeMonitorIdx >= 0
                readonly property bool isSecondaryActive: workspaceIndicator.activeMonitorIdx > 0
                readonly property bool isOccupied: !workspaceIndicator.isActive && (workspaceIndicator.index < root.workspaceOccupied.length ? root.workspaceOccupied[workspaceIndicator.index] : false)
                readonly property bool isHovered: mouseArea.containsMouse

                // Size: active is pill, others are dots
                Layout.preferredWidth: workspaceIndicator.isActive ? 24 : 8
                Layout.preferredHeight: 8
                radius: height / 2

                // Solid fill colors - use secondary color for second monitor's active workspace
                color: {
                    if (workspaceIndicator.isActive) {
                        return workspaceIndicator.isSecondaryActive ? root.activeSecondaryColor : root.activeColor
                    } else if (workspaceIndicator.isHovered) {
                        return Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.6)
                    } else if (workspaceIndicator.isOccupied) {
                        return root.occupiedColor
                    } else {
                        return root.emptyColor
                    }
                }

                opacity: (workspaceIndicator.isActive || workspaceIndicator.isOccupied || workspaceIndicator.isHovered) ? 1.0 : 0.4

                // Single synchronized animation for width
                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Hyprland.dispatch("workspace " + workspaceIndicator.workspaceId)
                    }
                }
            }
        }

        // Divider - only visible when multiple monitors are attached
        Rectangle {
            id: divider
            visible: root.hasMultipleMonitors
            Layout.preferredWidth: 1
            Layout.preferredHeight: 12
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            color: root.dividerColor
            opacity: 0.6

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        // Secondary workspaces (11-20) - only visible when multiple monitors are attached
        Repeater {
            model: root.hasMultipleMonitors ? 10 : 0

            Rectangle {
                id: secondaryWorkspaceIndicator
                required property int index
                readonly property int workspaceId: 10 + secondaryWorkspaceIndicator.index + 1
                readonly property int activeMonitorIdx: root.getActiveMonitorIndex(secondaryWorkspaceIndicator.workspaceId)
                readonly property bool isActive: secondaryWorkspaceIndicator.activeMonitorIdx >= 0
                readonly property bool isSecondaryActive: secondaryWorkspaceIndicator.activeMonitorIdx > 0
                readonly property bool isOccupied: !secondaryWorkspaceIndicator.isActive && (secondaryWorkspaceIndicator.index < root.secondaryWorkspaceOccupied.length ? root.secondaryWorkspaceOccupied[secondaryWorkspaceIndicator.index] : false)
                readonly property bool isHovered: secondaryMouseArea.containsMouse

                // Size: active is pill, others are dots
                Layout.preferredWidth: secondaryWorkspaceIndicator.isActive ? 24 : 8
                Layout.preferredHeight: 8
                radius: height / 2

                // Solid fill colors - use secondary color for second monitor's active workspace
                color: {
                    if (secondaryWorkspaceIndicator.isActive) {
                        return secondaryWorkspaceIndicator.isSecondaryActive ? root.activeSecondaryColor : root.activeColor
                    } else if (secondaryWorkspaceIndicator.isHovered) {
                        return Qt.rgba(root.activeSecondaryColor.r, root.activeSecondaryColor.g, root.activeSecondaryColor.b, 0.6)
                    } else if (secondaryWorkspaceIndicator.isOccupied) {
                        return root.occupiedColor
                    } else {
                        return root.emptyColor
                    }
                }

                opacity: (secondaryWorkspaceIndicator.isActive || secondaryWorkspaceIndicator.isOccupied || secondaryWorkspaceIndicator.isHovered) ? 1.0 : 0.4

                // Single synchronized animation for width
                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                MouseArea {
                    id: secondaryMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Hyprland.dispatch("workspace " + secondaryWorkspaceIndicator.workspaceId)
                    }
                }
            }
        }
    }

    function updateWorkspaceOccupied() {
        // Update primary workspaces (1-10)
        root.workspaceOccupied = Array.from({ length: 10}, (_, i) => {
            const workspaceId = i + 1;
            return Hyprland.workspaces.values.some(ws => ws.id === workspaceId);
        })

        // Update secondary workspaces (11-20)
        root.secondaryWorkspaceOccupied = Array.from({ length: 10}, (_, i) => {
            const workspaceId = 10 + i + 1;
            return Hyprland.workspaces.values.some(ws => ws.id === workspaceId);
        })
    }

    Component.onCompleted: {
        root.updateWorkspaceOccupied()
    }

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            root.updateWorkspaceOccupied()
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.updateWorkspaceOccupied()
        }
    }

    // Also update when monitors change
    Connections {
        target: Hyprland.monitors
        function onValuesChanged() {
            root.updateWorkspaceOccupied()
        }
    }
}

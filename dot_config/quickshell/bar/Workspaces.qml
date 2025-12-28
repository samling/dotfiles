pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.common

Item {
    id: root

    // Theme colors
    property color activeColor: Config.getColor("workspace.active")
    property color activeSecondaryColor: Config.getColor("workspace.activeSecondary")
    property color inactiveColor: Config.getColor("text.muted")

    // All occupied workspace IDs
    property var occupiedWorkspaces: []

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

    function updateWorkspaces() {
        root.occupiedWorkspaces = Hyprland.workspaces.values
            .map(ws => ws.id)
            .filter(id => id > 0)
            .sort((a, b) => a - b)
    }

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: workspaceRow.implicitHeight

    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: root.occupiedWorkspaces

            Text {
                id: wsLabel
                required property int modelData
                readonly property int workspaceId: modelData
                readonly property int activeMonitorIdx: root.getActiveMonitorIndex(wsLabel.workspaceId)
                readonly property bool isActive: wsLabel.activeMonitorIdx >= 0
                readonly property bool isSecondaryMonitor: wsLabel.activeMonitorIdx > 0
                readonly property bool isHovered: mouseArea.containsMouse

                text: wsLabel.workspaceId.toString()
                font.pixelSize: 14
                font.bold: wsLabel.isActive
                font.family: "monospace"

                color: {
                    if (wsLabel.isActive) {
                        return wsLabel.isSecondaryMonitor ? root.activeSecondaryColor : root.activeColor
                    } else if (wsLabel.isHovered) {
                        return Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.8)
                    } else {
                        return root.inactiveColor
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Hyprland.dispatch("workspace " + wsLabel.workspaceId)
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        root.updateWorkspaces()
    }

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            root.updateWorkspaces()
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            root.updateWorkspaces()
        }
    }

    Connections {
        target: Hyprland.monitors
        function onValuesChanged() {
            root.updateWorkspaces()
        }
    }
}

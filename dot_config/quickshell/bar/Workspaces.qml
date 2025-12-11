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
    readonly property int workspaceGroup: Math.floor((monitor?.activeWorkspace?.id - 1) / 10)
    property list<bool> workspaceOccupied: []

    // Theme colors
    property color activeColor: Config.getColor("primary.lavender")
    property color occupiedColor: Config.getColor("border.primary")
    property color emptyColor: Config.getColor("text.muted")

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: workspaceRow.implicitHeight

    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: 10

            Rectangle {
                id: workspaceIndicator
                required property int index
                readonly property int workspaceId: root.workspaceGroup * 10 + workspaceIndicator.index + 1
                readonly property bool isActive: root.monitor?.activeWorkspace?.id === workspaceIndicator.workspaceId
                readonly property bool isOccupied: !workspaceIndicator.isActive && (workspaceIndicator.index < root.workspaceOccupied.length ? root.workspaceOccupied[workspaceIndicator.index] : false)
                readonly property bool isHovered: mouseArea.containsMouse

                // Size: active is pill, others are dots
                Layout.preferredWidth: workspaceIndicator.isActive ? 24 : 8
                Layout.preferredHeight: 8
                radius: height / 2

                // Solid fill colors
                color: {
                    if (workspaceIndicator.isActive) {
                        return root.activeColor
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
    }

    function updateWorkspaceOccupied() {
        root.workspaceOccupied = Array.from({ length: 10}, (_, i) => {
            const workspaceId = root.workspaceGroup * 10 + i + 1;
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

    onWorkspaceGroupChanged: {
        root.updateWorkspaceOccupied()
    }
}

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
    
    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: workspaceRow.implicitHeight
    
    
    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: Config.workspaceSpacing
        
        Repeater {
            model: 10 // Restore all workspaces
            
            Item {
                id: workspaceContainer
                required property int index
                readonly property int workspaceId: root.workspaceGroup * 10 + workspaceContainer.index + 1
                readonly property bool isActive: root.monitor?.activeWorkspace?.id === workspaceContainer.workspaceId
                readonly property bool isOccupied: !workspaceContainer.isActive && (workspaceContainer.index < root.workspaceOccupied.length ? root.workspaceOccupied[workspaceContainer.index] : false)
                
                // Container size: circle width, or exact pill width with no extra margin
                width: workspaceContainer.isActive ? Config.workspaceWidth * 1.5 : Config.workspaceHeight
                height: Config.workspaceHeight
                
                // Ensure RowLayout respects the width changes
                Layout.preferredWidth: width
                Layout.fillWidth: false
                
                // Smooth container width animation
                Behavior on width {
                    NumberAnimation { duration: Config.colorAnimationDuration }
                }
                
                Rectangle {
                    id: workspaceIndicator
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: workspaceContainer.isActive ? Config.workspaceWidth * 1.5 : Config.workspaceHeight
                    height: Config.workspaceHeight
                    radius: Config.workspaceHeight / 2
                    color: {
                        if (workspaceContainer.isActive) {
                            return Config.workspaceActiveColor
                        } else if (workspaceContainer.isOccupied) {
                            return Config.workspaceOccupiedColor
                        } else {
                            return Config.workspaceEmptyColor
                        }
                    }
                    
                    // Reduce opacity for empty workspaces
                    opacity: (!workspaceContainer.isActive && !workspaceContainer.isOccupied) ? 0.6 : 1.0
                    
                    // Smooth color transition
                    Behavior on color {
                        ColorAnimation { duration: Config.colorAnimationDuration }
                    }
                }
                
                // Click to switch workspace
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Hyprland.dispatch("workspace " + workspaceContainer.workspaceId)
                    }
                    
                    // Hover effect
                    hoverEnabled: true
                    onEntered: workspaceIndicator.opacity = 0.8
                    onExited: workspaceIndicator.opacity = 1.0
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
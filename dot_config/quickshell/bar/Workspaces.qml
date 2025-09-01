pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
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
            model: 10 // Show workspaces 1-10 for the current group
            
            Rectangle {
                id: workspaceIndicator
                required property int index
                readonly property int workspaceId: root.workspaceGroup * 10 + workspaceIndicator.index + 1
                readonly property bool isActive: root.monitor?.activeWorkspace?.id === workspaceIndicator.workspaceId
                readonly property bool isOccupied: workspaceIndicator.index < root.workspaceOccupied.length ? root.workspaceOccupied[workspaceIndicator.index] : false
                
                width: Config.workspaceWidth
                height: Config.workspaceHeight
                radius: Config.workspaceRadius
                
                // Color logic: blue if occupied, gray if not, highlighted if active
                color: {
                    if (workspaceIndicator.isActive) {
                        return workspaceIndicator.isOccupied ? Config.workspaceActiveColor : Config.workspaceActiveBrightColor
                    } else if (workspaceIndicator.isOccupied) {
                        return Config.workspaceOccupiedColor
                    } else {
                        return Config.workspaceEmptyColor
                    }
                }
                
                border.color: workspaceIndicator.isActive ? Config.workspaceActiveBorderColor : "transparent"
                border.width: workspaceIndicator.isActive ? Config.workspaceBorderWidth : 0
                
                // Workspace number text
                Text {
                    anchors.centerIn: parent
                    text: (workspaceIndicator.index + 1)
                    color: workspaceIndicator.isActive ? Config.workspaceActiveTextColor : (workspaceIndicator.isOccupied ? Config.workspaceOccupiedTextColor : Config.workspaceEmptyTextColor)
                    font.pixelSize: Config.workspaceFontSize
                    font.bold: workspaceIndicator.isActive
                }
                
                // Click to switch workspace
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Hyprland.dispatch("workspace " + workspaceIndicator.workspaceId)
                    }
                    
                    // Hover effect
                    hoverEnabled: true
                    onEntered: parent.opacity = 0.8
                    onExited: parent.opacity = 1.0
                }
                
                // Smooth transitions
                Behavior on color {
                    ColorAnimation { duration: Config.colorAnimationDuration }
                }
                
                Behavior on border.color {
                    ColorAnimation { duration: Config.colorAnimationDuration }
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
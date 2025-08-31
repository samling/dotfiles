pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

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
        spacing: 4
        
        Repeater {
            model: 10 // Show workspaces 1-10 for the current group
            
            Rectangle {
                id: workspaceIndicator
                required property int index
                readonly property int workspaceId: root.workspaceGroup * 10 + workspaceIndicator.index + 1
                readonly property bool isActive: root.monitor?.activeWorkspace?.id === workspaceIndicator.workspaceId
                readonly property bool isOccupied: workspaceIndicator.index < root.workspaceOccupied.length ? root.workspaceOccupied[workspaceIndicator.index] : false
                
                width: 24
                height: 20
                radius: 4
                
                // Color logic: blue if occupied, gray if not, highlighted if active
                color: {
                    if (workspaceIndicator.isActive) {
                        return workspaceIndicator.isOccupied ? "#6c7ff2" : "#5a6cf0" // Bright blue variants for active
                    } else if (workspaceIndicator.isOccupied) {
                        return "#4a5568" // Dark blue-gray for occupied
                    } else {
                        return "#2d3748" // Dark gray for empty
                    }
                }
                
                border.color: workspaceIndicator.isActive ? "#ffffff" : "transparent"
                border.width: workspaceIndicator.isActive ? 2 : 0
                
                // Workspace number text
                Text {
                    anchors.centerIn: parent
                    text: (workspaceIndicator.index + 1)
                    color: workspaceIndicator.isActive ? "#ffffff" : (workspaceIndicator.isOccupied ? "#e2e8f0" : "#718096")
                    font.pixelSize: 11
                    font.bold: workspaceIndicator.isActive
                }
                
                // Click to switch workspace
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Hyprland.dispatch("workspace", workspaceIndicator.workspaceId.toString())
                    }
                    
                    // Hover effect
                    hoverEnabled: true
                    onEntered: parent.opacity = 0.8
                    onExited: parent.opacity = 1.0
                }
                
                // Smooth transitions
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
                
                Behavior on border.color {
                    ColorAnimation { duration: 200 }
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
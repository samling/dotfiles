import qs.services
import QtQuick
import QtQuick.Layouts
import qs.common

MouseArea {
    id: root
    
    readonly property bool connected: Tailscale.connected
    readonly property string nodeName: Tailscale.nodeName
    readonly property string tailnetName: Tailscale.tailnetName
    
    property int iconSize: Config.barHeight - 16
    property int dotSize: Math.floor(iconSize / 5) // 3x3 grid with spacing
    property int dotSpacing: Math.floor(dotSize * 0.8)
    property color connectedColor: Config.getColor("text.white")
    property color disconnectedColor: Config.getColor("text.muted")
    
    implicitWidth: iconSize + 12
    implicitHeight: iconSize
    hoverEnabled: true
    
    onClicked: {
        Tailscale.toggleConnection()
    }
    
    // 3x3 dot matrix container
    Item {
        id: dotMatrix
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        
        // Calculate positions for 3x3 grid
        readonly property int gridSize: root.dotSize * 3 + root.dotSpacing * 2
        readonly property int startX: (root.iconSize - gridSize) / 2
        readonly property int startY: (root.iconSize - gridSize) / 2
        
        // Top row (all dots lit when connected, forming top of "T")
        Rectangle {
            id: dot1
            x: dotMatrix.startX
            y: dotMatrix.startY
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.connected ? root.connectedColor : root.disconnectedColor
            opacity: root.connected ? 1.0 : 0.3
            
            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
            Behavior on opacity { NumberAnimation { duration: Config.colorAnimationDuration } }
        }
        
        Rectangle {
            id: dot2
            x: dotMatrix.startX + root.dotSize + root.dotSpacing
            y: dotMatrix.startY
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.connected ? root.connectedColor : root.disconnectedColor
            opacity: root.connected ? 1.0 : 0.3
            
            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
            Behavior on opacity { NumberAnimation { duration: Config.colorAnimationDuration } }
        }
        
        Rectangle {
            id: dot3
            x: dotMatrix.startX + (root.dotSize + root.dotSpacing) * 2
            y: dotMatrix.startY
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.connected ? root.connectedColor : root.disconnectedColor
            opacity: root.connected ? 1.0 : 0.3
            
            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
            Behavior on opacity { NumberAnimation { duration: Config.colorAnimationDuration } }
        }
        
        // Middle row (only center dot lit when connected, forming stem of "T")
        Rectangle {
            id: dot4
            x: dotMatrix.startX
            y: dotMatrix.startY + root.dotSize + root.dotSpacing
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.disconnectedColor
            opacity: root.connected ? 0.3 : 0.3
            
            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
            Behavior on opacity { NumberAnimation { duration: Config.colorAnimationDuration } }
        }
        
        Rectangle {
            id: dot5
            x: dotMatrix.startX + root.dotSize + root.dotSpacing
            y: dotMatrix.startY + root.dotSize + root.dotSpacing
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.connected ? root.connectedColor : root.disconnectedColor
            opacity: root.connected ? 1.0 : 0.3
            
            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
            Behavior on opacity { NumberAnimation { duration: Config.colorAnimationDuration } }
        }
        
        Rectangle {
            id: dot6
            x: dotMatrix.startX + (root.dotSize + root.dotSpacing) * 2
            y: dotMatrix.startY + root.dotSize + root.dotSpacing
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.disconnectedColor
            opacity: root.connected ? 0.3 : 0.3
            
            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
            Behavior on opacity { NumberAnimation { duration: Config.colorAnimationDuration } }
        }
        
        // Bottom row (only center dot lit when connected, forming stem of "T")
        Rectangle {
            id: dot7
            x: dotMatrix.startX
            y: dotMatrix.startY + (root.dotSize + root.dotSpacing) * 2
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.disconnectedColor
            opacity: root.connected ? 0.3 : 0.3
            
            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
            Behavior on opacity { NumberAnimation { duration: Config.colorAnimationDuration } }
        }
        
        Rectangle {
            id: dot8
            x: dotMatrix.startX + root.dotSize + root.dotSpacing
            y: dotMatrix.startY + (root.dotSize + root.dotSpacing) * 2
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.connected ? root.connectedColor : root.disconnectedColor
            opacity: root.connected ? 1.0 : 0.3
            
            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
            Behavior on opacity { NumberAnimation { duration: Config.colorAnimationDuration } }
        }
        
        Rectangle {
            id: dot9
            x: dotMatrix.startX + (root.dotSize + root.dotSpacing) * 2
            y: dotMatrix.startY + (root.dotSize + root.dotSpacing) * 2
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.disconnectedColor
            opacity: root.connected ? 0.3 : 0.3
            
            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
            Behavior on opacity { NumberAnimation { duration: Config.colorAnimationDuration } }
        }
    }
    
    Tooltip {
        hoverTarget: root
        text: {
            if (root.connected) {
                let details = "Tailscale: Connected"
                if (root.nodeName) details += "\nNode: " + root.nodeName
                if (root.tailnetName) details += "\nIP: " + root.tailnetName
                if (Tailscale.tailnetDomain) details += "\nDomain: " + Tailscale.tailnetDomain
                
                // Add connected peers
                if (Tailscale.connectedPeers && Tailscale.connectedPeers.length > 0) {
                    details += "\n\nConnected Devices:"
                    for (let i = 0; i < Tailscale.connectedPeers.length; i++) {
                        const peer = Tailscale.connectedPeers[i]
                        details += "\n• " + peer.hostname + " (" + peer.ip + ")"
                        if (peer.os) details += " [" + peer.os + "]"
                    }
                } else {
                    details += "\n\nNo other devices connected"
                }
                
                details += "\n\nClick to disconnect"
                return details
            } else {
                let details = "Tailscale: Disconnected"
                if (!Tailscale.userMode) {
                    details += "\nNote: Run 'sudo tailscale set --operator=$USER' for user control"
                }
                details += "\nClick to connect"
                return details
            }
        }
    }
}

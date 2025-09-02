pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common

Item {
    id: root
    
    property MouseArea hoverTarget
    property string text: ""
    property bool isHovering: hoverTarget && hoverTarget.containsMouse && text.length > 0
    property bool shouldShow: false
    
    onIsHoveringChanged: {
        if (!isHovering) {
            shouldShow = false
        }
    }
    
    Timer {
        id: showTimer
        interval: 500
        repeat: false
        running: root.isHovering
        onTriggered: {
            root.shouldShow = true
        }
        onRunningChanged: {
            if (!running && !root.isHovering) {
                root.shouldShow = false
            }
        }
    }
    
    LazyLoader {
        active: root.shouldShow
        
        component: PanelWindow {
        id: tooltipWindow
        color: "transparent"
        
        // Simple positioning - position as a floating overlay
        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }
        
        implicitWidth: tooltipContent.implicitWidth
        implicitHeight: tooltipContent.implicitHeight
        
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        
        WlrLayershell.namespace: "quickshell:tooltip"
        WlrLayershell.layer: WlrLayer.Overlay
        
        Rectangle {
            id: tooltipContent
            
            // Position manually relative to hover target
            x: {
                if (!root.hoverTarget) return 0;
                const globalPos = root.hoverTarget.mapToGlobal(0, 0);
                const centeredX = globalPos.x + (root.hoverTarget.width - width) / 2;
                return Math.max(0, Math.min(centeredX, parent.width - width));
            }
            y: {
                if (!root.hoverTarget) return 0;
                const globalPos = root.hoverTarget.mapToGlobal(0, 0);
                return globalPos.y + root.hoverTarget.height + 8;
            }
            color: Config.tooltipBackgroundColor
            border.color: Config.tooltipBorderColor
            border.width: 1
            radius: 6
            
            implicitWidth: tooltipText.implicitWidth + 16
            implicitHeight: tooltipText.implicitHeight + 12
            
            // Subtle shadow
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 2
                anchors.leftMargin: 2
                color: Config.tooltipShadowColor
                opacity: Config.tooltipShadowOpacity
                radius: parent.radius
                z: -1
            }
            
            Text {
                id: tooltipText
                anchors.centerIn: parent
                color: Config.tooltipTextColor
                font.pixelSize: 12
                font.weight: Font.Medium
                text: root.text
            }
        }
        }
    }
}

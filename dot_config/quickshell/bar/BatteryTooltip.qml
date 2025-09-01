import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services

LazyLoader {
    id: root
    
    property Item hoverTarget
    property bool shouldShow: hoverTarget && hoverTarget.containsMouse
    
    active: shouldShow
    
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
        
        WlrLayershell.namespace: "quickshell:battery-tooltip"
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
            color: "#2D3748"
            border.color: "#4A5568"
            border.width: 1
            radius: 6
            
            implicitWidth: tooltipText.implicitWidth + 16
            implicitHeight: tooltipText.implicitHeight + 12
            
            // Subtle shadow
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 2
                anchors.leftMargin: 2
                color: "#000000"
                opacity: 0.3
                radius: parent.radius
                z: -1
            }
            
            Text {
                id: tooltipText
                anchors.centerIn: parent
                color: "#E2E8F0"
                font.pixelSize: 12
                font.weight: Font.Medium
                
                text: {
                    if (!Battery.available) return "Battery not available";
                    
                    // Show more useful info when time is unknown
                    if (Battery.timeString === "Time unknown") {
                        if (Battery.isCharging) {
                            return "Charging: " + Math.round(Battery.percentage * 100) + "%";
                        } else if (Battery.isPluggedIn) {
                            return "Plugged in: " + Math.round(Battery.percentage * 100) + "% (Full)";
                        } else {
                            return "Battery: " + Math.round(Battery.percentage * 100) + "%";
                        }
                    }
                    
                    return Battery.timeString;
                }
            }
        }
    }
}

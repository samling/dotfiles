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
    // Pin the tooltip's layer surface to the same output as the hover
    // target. Without this, on multi-monitor setups the PanelWindow
    // falls back to the default screen and mapToGlobal coordinates
    // land outside its bounds, leaving the tooltip invisible.
    readonly property var targetScreen: hoverTarget && hoverTarget.QsWindow.window
        ? hoverTarget.QsWindow.window.screen
        : null
    
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
        screen: root.targetScreen
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

        // Without a mask, the full-screen overlay catches cursor input
        // across the whole screen — that steals hover from the bar
        // widget that triggered the tooltip and causes it to flicker on
        // and off. Restricting input to just the tooltip rectangle lets
        // cursor events pass through the transparent surround.
        mask: Region { item: tooltipContent }

        Rectangle {
            id: tooltipContent
            
            // Position manually relative to hover target.
            // mapToGlobal returns desktop-global coords; the tooltip
            // PanelWindow's local coordinate space starts at 0 on its
            // own output, so we subtract the screen origin.
            x: {
                if (!root.hoverTarget || !tooltipWindow.screen) return 0;
                const globalPos = root.hoverTarget.mapToGlobal(0, 0);
                const localX = globalPos.x - tooltipWindow.screen.x;
                const centeredX = localX + (root.hoverTarget.width - width) / 2;
                return Math.max(0, Math.min(centeredX, parent.width - width));
            }
            y: {
                if (!root.hoverTarget || !tooltipWindow.screen) return 0;
                const globalPos = root.hoverTarget.mapToGlobal(0, 0);
                const localY = globalPos.y - tooltipWindow.screen.y;
                return localY + root.hoverTarget.height + 8;
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
                font.pixelSize: Config.fontSizeMedium
                font.weight: Font.Medium
                font.family: Config.fontFamilyMonospace
                text: root.text
            }
        }
        }
    }
}

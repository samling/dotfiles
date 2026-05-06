pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services

// Niri-only narrow vertical bar on the left edge. Hosts the workspaces
// widget; pairs with the horizontal top bar so the spatial layout
// matches niri's axes (workspaces vertical, columns horizontal).
//
// Lives on the Top layer so niri renders it once (not per-workspace) —
// otherwise the bar would animate with each workspace switch.
Scope {
    id: scope

    Variants {
        model: Quickshell.screens

        LazyLoader {
            id: sideLoader
            required property ShellScreen modelData
            active: Compositor.isNiri

            component: PanelWindow {
                id: sideRoot
                screen: sideLoader.modelData
                implicitWidth: Config.sideBarWidth
                color: "transparent"

                WlrLayershell.namespace: "quickshell:sidebar"
                WlrLayershell.layer: WlrLayer.Top
                exclusiveZone: Config.sideBarWidth

                anchors {
                    top: true
                    left: true
                    bottom: true
                }

                Rectangle {
                    id: pill
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: Config.sideBarLeftMargin
                        right: parent.right
                    }
                    height: workspaces.implicitHeight + Config.pillHorizontalPadding * 2
                    color: Config.pillColor2
                    radius: Config.pillRadius
                    border.width: 2
                    border.color: Qt.darker(color, 1.3)

                    readonly property color textColor: Config.contrastText(color)

                    Workspaces {
                        id: workspaces
                        anchors.centerIn: parent
                        activeColor: pill.textColor
                        activeSecondaryColor: pill.textColor
                        inactiveColor: Qt.darker(pill.textColor, 1.4)
                    }
                }
            }
        }
    }
}

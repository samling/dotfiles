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

                Workspaces {
                    id: workspaces
                    anchors.left: parent.left
                    anchors.leftMargin: Config.sideBarLeftMargin
                    anchors.verticalCenter: parent.verticalCenter
                    activeColor: Config.niriWorkspaceTextColor
                    activeSecondaryColor: Config.niriWorkspaceTextColor
                    inactiveColor: Qt.darker(Config.niriWorkspaceTextColor, 1.4)
                    outputFilter: sideLoader.modelData.name
                }
            }
        }
    }
}

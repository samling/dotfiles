
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common

Scope {
    id: bar

    Variants {
        model: Quickshell.screens

        LazyLoader {
            id: barLoader
            active: true
            required property ShellScreen modelData
            component: PanelWindow {
                id: barRoot
                screen: barLoader.modelData
                implicitHeight: Config.barHeight
                color: "transparent"
                
                // Layer configuration for proper popup handling
                WlrLayershell.namespace: "quickshell:bar"
                WlrLayershell.layer: WlrLayer.Bottom
                exclusiveZone: Config.barHeight
                
                anchors {
                    top: true
                    left: true
                    right: true
                }

                MouseArea {
                    id: hoverRegion
                    hoverEnabled: true
                    anchors.fill: parent

                    BarContent {
                        id: barContent
                        implicitHeight: Config.barHeight
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            bottom: undefined

                        }
                    }
                }
            }
        }
    }
}
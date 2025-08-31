import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower

Scope {
    id: bar

    Variants {
        model: {
            const screens = Quickshell.screens;
            return screens;
        }

        LazyLoader {
            id: barLoader
            active: true
            required property ShellScreen modelData
            component: PanelWindow {
                id: barRoot
                screen: barLoader.modelData
                implicitHeight: 40
                color: "transparent"
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
                        implicitHeight: 40
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
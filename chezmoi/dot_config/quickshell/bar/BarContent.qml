import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common

Item {
    id: root
    property var screen: root.QsWindow.window?.screen

    InfoPanel {
        cpuIndicator: cpuWidget
        memIndicator: memoryWidget
        diskIndicator: diskWidget
    }

    // Left section
    RowLayout {
        id: leftSection
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            leftMargin: Config.barContentLeftMargin
        }
        spacing: Config.pillSpacing

        BarGroup {
            id: powerGroup
            accentColor: Config.pillColor1
            Layout.fillHeight: true

            PowerMenu {
                id: powerMenuWidget
                primaryColor: powerGroup.textColor
            }
        }

        BarGroup {
            id: workspacesGroup
            accentColor: Config.pillColor2
            Layout.fillHeight: true

            Workspaces {
                id: workspacesWidget
                activeColor: workspacesGroup.textColor
                activeSecondaryColor: workspacesGroup.textColor
                inactiveColor: Qt.darker(workspacesGroup.textColor, 1.4)
            }
        }
    }

    // Middle section
    RowLayout {
        id: middleSection
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Config.pillSpacing

        BarGroup {
            id: clockGroup
            accentColor: Config.pillColor1
            Layout.fillHeight: true

            ClockWidget {
                id: clockWidget
                primaryColor: clockGroup.textColor
                secondaryColor: clockGroup.textColor
            }
        }
    }

    // Right section
    RowLayout {
        id: rightSection
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: Config.barContentRightMargin
        }
        spacing: Config.pillSpacing

        BarGroup {
            id: sysTrayGroup
            accentColor: Config.pillColor9
            Layout.fillHeight: true

            SysTray {
                id: sysTrayWidget
            }
        }

        BarGroup {
            id: tailscaleGroup
            accentColor: Config.pillColor8
            Layout.fillHeight: true

            TailscaleIndicator {
                id: tailscaleWidget
                connectedColor: tailscaleGroup.textColor
                disconnectedColor: Qt.lighter(tailscaleGroup.textColor, 1.4)
            }
        }

        BarGroup {
            id: networkGroup
            accentColor: Config.pillColor5
            Layout.fillHeight: true

            NetworkIndicator {
                id: networkWidget
                primaryColor: networkGroup.textColor
            }
        }

        BarGroup {
            id: cpuGroup
            accentColor: Config.pillColor6
            Layout.fillHeight: true

            CpuIndicator {
                id: cpuWidget
                primaryColor: cpuGroup.textColor
            }
        }

        BarGroup {
            id: memoryGroup
            accentColor: Config.pillColor7
            Layout.fillHeight: true

            MemoryIndicator {
                id: memoryWidget
                primaryColor: memoryGroup.textColor
            }
        }

        BarGroup {
            id: diskGroup
            accentColor: Config.pillColor8
            Layout.fillHeight: true

            DiskIndicator {
                id: diskWidget
                primaryColor: diskGroup.textColor
            }
        }

        BarGroup {
            id: batteryGroup
            accentColor: Config.pillColor9
            Layout.fillHeight: true

            BatteryIndicator {
                id: batteryWidget
                primaryColor: batteryGroup.textColor
            }
        }

        BarGroup {
            id: volumeGroup
            accentColor: Config.pillColor10
            Layout.fillHeight: true

            VolumeIndicator {
                id: volumeWidget
                primaryColor: volumeGroup.textColor
            }
        }

        // BarGroup {
        //     id: updatesGroup
        //     accentColor: Config.pillColor11
        //     Layout.fillHeight: true
        //
        //     Updates {
        //         id: updatesWidget
        //         primaryColor: updatesGroup.textColor
        //     }
        // }

        BarGroup {
            id: notificationGroup
            accentColor: Config.pillColor12
            Layout.fillHeight: true

            NotificationButton {
                id: notificationButton
                primaryColor: notificationGroup.textColor
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common

Item {
    id: root
    property var screen: root.QsWindow.window?.screen

    InfoPanel {
        cpuIndicator: cpuWidget
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
            accentColor: Config.pillColor1
            Layout.fillHeight: true

            PowerMenu {
                id: powerMenuWidget
            }
        }

        BarGroup {
            accentColor: Config.pillColor2
            Layout.fillHeight: true

            Workspaces {
                id: workspacesWidget
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
            accentColor: Config.pillColor3
            Layout.fillHeight: true

            ClockWidget {
                id: clockWidget
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
            accentColor: Config.pillColor4
            Layout.fillHeight: true

            SysTray {
                id: sysTrayWidget
            }
        }

        BarGroup {
            accentColor: Config.pillColor5
            Layout.fillHeight: true

            TailscaleIndicator {
                id: tailscaleWidget
            }
        }

        BarGroup {
            accentColor: Config.pillColor6
            Layout.fillHeight: true

            CpuIndicator {
                id: cpuWidget
            }
        }

        BarGroup {
            accentColor: Config.pillColor7
            Layout.fillHeight: true

            MemoryIndicator {
                id: memoryWidget
            }
        }

        BarGroup {
            accentColor: Config.pillColor8
            Layout.fillHeight: true

            DiskIndicator {
                id: diskWidget
            }
        }

        BarGroup {
            accentColor: Config.pillColor9
            Layout.fillHeight: true

            BatteryIndicator {
                id: batteryWidget
            }
        }

        BarGroup {
            accentColor: Config.pillColor10
            Layout.fillHeight: true

            VolumeIndicator {
                id: volumeWidget
            }
        }

        BarGroup {
            accentColor: Config.pillColor11
            Layout.fillHeight: true

            Updates {
                id: updatesWidget
            }
        }

        BarGroup {
            accentColor: Config.pillColor12
            Layout.fillHeight: true

            NotificationButton {
                id: notificationButton
            }
        }
    }
}

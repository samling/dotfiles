import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common

Item {
    id: root
    property var screen: root.QsWindow.window?.screen

    Rectangle { // background
        id: barBackground
        anchors {
            fill: parent
            margins: 0
        }
        color: Config.barBackgroundColor
        radius: Config.barRadius
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
        spacing: Config.barContentSpacing

        PowerMenu {
            id: powerMenuWidget
            Layout.fillHeight: true
        }

        Item { 
            Layout.preferredWidth: 4
            Layout.preferredHeight: 1
        } // Spacer

        Workspaces {
            id: workspacesWidget
            Layout.fillHeight: true
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
        spacing: Config.barContentSpacing

        BarGroup {
            id: middleGroupContent
            Layout.fillHeight: true

            ClockWidget {
                id: clockWidget
                Layout.fillHeight: true
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
        spacing: Config.barContentSpacing

        BarGroup {
            id: rightGroupContent
            Layout.fillHeight: true
            Layout.fillWidth: false

            SysTray {
                id: sysTrayWidget
                Layout.fillHeight: true
            }

            Item { width: 6; height: 1 }

            TailscaleIndicator {
                id: tailscaleWidget
                Layout.fillHeight: true
            }

            Item { width: 6; height: 1 }

            CpuIndicator {
                id: cpuWidget
                Layout.fillHeight: true
            }

            Item { width: 6; height: 1 }

            MemoryIndicator {
                id: memoryWidget
                Layout.fillHeight: true
            }

            Item { width: 6; height: 1 }

            DiskIndicator {
                id: diskWidget
                Layout.fillHeight: true
            }

            Item { width: 6; height: 1 }

            BatteryIndicator {
                id: batteryWidget
                Layout.fillHeight: true
            }

            Item { width: 6; height: 1 }

            Updates {
                id: updatesWidget
                Layout.fillHeight: true
            }

            Item { width: 6; height: 1 }

            NotificationButton {
                id: notificationButton
                Layout.fillHeight: true
            }

        }
    }

}
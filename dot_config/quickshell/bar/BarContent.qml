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
            Layout.fillHeight: false

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
            Layout.fillHeight: false
            Layout.fillWidth: false

            SysTray {
                id: sysTrayWidget
                Layout.fillHeight: true
            }

            Item { width: 8; height: 1 } // Spacer

            TailscaleIndicator {
                id: tailscaleWidget
                Layout.fillHeight: true
            }

            Item { width: 8; height: 1 } // Spacer

            BatteryIndicator {
                id: batteryWidget
                Layout.fillHeight: true
            }

            Item { width: 8; height: 1 } // Spacer

            Updates {
                id: updatesWidget
                Layout.fillHeight: true
            }

            Item { width: 8; height: 1 } // Spacer

            NotificationButton {
                id: notificationButton
                Layout.fillHeight: true
            }

        }
    }

}
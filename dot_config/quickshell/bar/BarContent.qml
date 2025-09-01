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
            margins: 1
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

        BarGroup {
            id: leftGroup
            Layout.fillHeight: false

            Workspaces {
                id: workspacesWidget
                Layout.fillHeight: true
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

            NotificationButton {
                id: notificationButton
                Layout.fillHeight: true
            }

            BatteryIndicator {
                id: batteryWidget
                Layout.fillHeight: true
            }
        }
    }

}
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

        ClockWidget {
            id: clockWidget
            Layout.fillHeight: true
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

        SysTray {
            id: sysTrayWidget
            Layout.fillHeight: true
        }

        TailscaleIndicator {
            id: tailscaleWidget
            Layout.fillHeight: true
        }

        CpuIndicator {
            id: cpuWidget
            Layout.fillHeight: true
        }

        MemoryIndicator {
            id: memoryWidget
            Layout.fillHeight: true
        }

        DiskIndicator {
            id: diskWidget
            Layout.fillHeight: true
        }

        BatteryIndicator {
            id: batteryWidget
            Layout.fillHeight: true
        }

        Updates {
            id: updatesWidget
            Layout.fillHeight: true
        }

        NotificationButton {
            id: notificationButton
            Layout.fillHeight: true
        }
    }

}
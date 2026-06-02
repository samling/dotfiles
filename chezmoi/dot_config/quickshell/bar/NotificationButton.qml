import qs.services
import qs.common
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root

    readonly property int notificationCount: Notifications.list.length
    readonly property bool hasNotifications: notificationCount > 0

    property color primaryColor: Config.barTextColor

    implicitWidth: notifRow.implicitWidth + 8
    implicitHeight: parent ? parent.height : Config.barHeight
    hoverEnabled: true

    onClicked: {
        PopoutCoordinator.toggleInfoPanel()
    }

    RowLayout {
        id: notifRow
        anchors.centerIn: parent
        spacing: 2

        // Bell icon
        Text {
            text: "🔔\uFE0E"
            color: root.primaryColor
            font.pixelSize: Config.fontSizeBase

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }

        // Count
        Text {
            text: root.notificationCount.toString()
            color: root.primaryColor
            font.pixelSize: Config.fontSizeBase
            font.weight: Font.DemiBold
            font.family: Config.fontFamilyMonospace

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }
    }

    Tooltip {
        hoverTarget: root
        text: root.hasNotifications
            ? root.notificationCount + " notification" + (root.notificationCount > 1 ? "s" : "")
            : "No notifications"
    }
}

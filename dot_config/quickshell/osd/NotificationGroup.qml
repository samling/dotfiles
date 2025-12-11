pragma ComponentBehavior: Bound

import QtQuick

Column {
    id: root
    property var notificationGroup
    property bool popup: false

    spacing: 8

    Repeater {
        model: root.notificationGroup?.notifications ?? []
        delegate: NotificationItem {
            required property var modelData
            width: root.width
            notificationObject: modelData
        }
    }
}

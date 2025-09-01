import qs.common
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    id: root
    property var notificationGroup
    property bool popup: false
    
    spacing: 3

    Repeater {
        model: notificationGroup?.notifications ?? []
        delegate: NotificationItem {
            width: root.width
            notificationObject: modelData
        }
    }
}

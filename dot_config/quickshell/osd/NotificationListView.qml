import qs.common
import qs.services
import QtQuick
import QtQuick.Controls
import Quickshell

ScrollView {
    id: root
    property bool popup: false
    property real realContentHeight: contentColumn.implicitHeight

    clip: true
    contentWidth: availableWidth

    Column {
        id: contentColumn
        width: root.availableWidth
        spacing: 3

        Repeater {
            model: ScriptModel {
                values: root.popup ? Notifications.popupAppNameList : Notifications.appNameList
            }
            delegate: NotificationGroup {
                width: parent.width
                popup: root.popup
                notificationGroup: popup ? 
                    Notifications.popupGroupsByAppName[modelData] :
                    Notifications.groupsByAppName[modelData]
            }
        }
    }
}

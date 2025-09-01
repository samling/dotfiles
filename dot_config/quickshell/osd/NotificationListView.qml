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
    contentHeight: realContentHeight
    
    ScrollBar.vertical.policy: ScrollBar.AsNeeded
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.active: true
    ScrollBar.vertical.visible: contentHeight > height
    
    // Disable default wheel handling so we can customize it
    wheelEnabled: false
    
    // Custom mouse area for faster wheel scrolling
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
        
        onWheel: (wheel) => {
            // Custom scroll distance - much larger than default
            const scrollDistance = wheel.angleDelta.y * 2  // Increase multiplier for faster scrolling
            if (root.contentItem) {
                root.contentItem.contentY = Math.max(0, 
                    Math.min(root.contentItem.contentY - scrollDistance, 
                             root.contentItem.contentHeight - root.contentItem.height))
            }
            wheel.accepted = true
        }
        
        onPressed: (mouse) => {
            mouse.accepted = false  // Let other mouse events pass through
        }
    }

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

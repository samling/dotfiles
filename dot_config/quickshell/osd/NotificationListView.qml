pragma ComponentBehavior: Bound

import qs.common
import qs.services
import QtQuick
import QtQuick.Controls
import Quickshell

ListView {
    id: root
    property bool popup: false
    property real realContentHeight: contentHeight

    clip: true
    spacing: 3
    
    // Scrollbar configuration
    ScrollBar.vertical: ScrollBar {
        id: scrollBar
        policy: ScrollBar.AsNeeded
        active: scrollTimer.running
        visible: parent.contentHeight > parent.height
        
        Timer {
            id: scrollTimer
            interval: 500  // Hide after 0.5 seconds of no scrolling
            repeat: false
        }
    }
    
    // Custom mouse area for faster wheel scrolling
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
        
        onWheel: (wheel) => {
            // Show scrollbar and restart timer
            scrollTimer.restart()
            
            // Custom scroll distance - much larger than default
            const scrollDistance = wheel.angleDelta.y * 2  // Increase multiplier for faster scrolling
            root.contentY = Math.max(0, 
                Math.min(root.contentY - scrollDistance, 
                         root.contentHeight - root.height))
            wheel.accepted = true
        }
        
        onPressed: (mouse) => {
            mouse.accepted = false  // Let other mouse events pass through
        }
    }
    
    model: ScriptModel {
        values: root.popup ? Notifications.popupAppNameList : Notifications.appNameList
    }
    
    delegate: NotificationGroup {
        required property int index
        required property var modelData
        popup: root.popup
        width: root.width
        notificationGroup: popup ? 
            Notifications.popupGroupsByAppName[modelData] :
            Notifications.groupsByAppName[modelData]
    }
}

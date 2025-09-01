import qs.services
import qs.common
import qs.osd
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    readonly property int notificationCount: Notifications.list.length
    readonly property bool hasNotifications: notificationCount > 0
    
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: rowLayout.implicitHeight
    
    // Toggle notification list popup
    property bool listOpen: false
    
    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: Config.batterySpacing
        
        Rectangle {
            id: notificationIcon
            width: 24
            height: 24
            radius: 4
            color: root.hasNotifications ? Config.notificationActiveColor : Config.notificationInactiveColor
            border.color: root.hasNotifications ? Config.notificationActiveAccentColor : Config.notificationBorderColor
            border.width: 1
            
            // Notification icon
            Text {
                anchors.centerIn: parent
                text: "🔔"
                font.pixelSize: 12
                visible: !root.hasNotifications
            }
            
            // Notification count
            Text {
                anchors.centerIn: parent
                text: root.notificationCount > 99 ? "99+" : root.notificationCount.toString()
                color: Config.notificationBackgroundColor
                font.pixelSize: root.notificationCount > 9 ? 9 : 11
                font.weight: Font.Bold
                visible: root.hasNotifications
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.listOpen = !root.listOpen
                    // Also update GlobalStates to prevent conflicts
                    GlobalStates.sidebarRightOpen = root.listOpen
                }
            }
        }
    }
    
    // Notification list popup
    PanelWindow {
        id: notificationListPopup
        visible: root.listOpen
        
        anchors {
            top: true
            right: true
            left: true
            bottom: true
        }
        
        margins.top: 5
        margins.right: 8
        margins.left: 200
        margins.bottom: 50
        
        color: "transparent"
        
        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.listOpen = false
                GlobalStates.sidebarRightOpen = false
            }
        }
        
        // Actual notification content
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            width: 400
            height: Math.min(parent.height * 0.8, 600)  // Fixed height constraint
            color: Config.notificationBackgroundColor
            border.color: Config.notificationBorderColor
            border.width: 2
            radius: 12
            
            // Prevent clicks from passing through to the background MouseArea
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Do nothing - just prevent click-through
                }
            }
        
            Column {
                id: notificationContent
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Header
                Row {
                    width: parent.width
                    spacing: 8
                    
                    Text {
                        text: "Notifications"
                        color: "#cdd6f4"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                    }
                    
                    Rectangle {
                        width: 60
                        height: 24
                        radius: 12
                        color: Config.notificationButtonColor
                        border.color: Config.notificationBorderColor
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Clear"
                            color: Config.notificationTextPrimaryColor
                            font.pixelSize: 11
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Notifications.discardAllNotifications()
                            }
                        }
                    }
                }
                
                // Notification list
                Rectangle {
                    width: parent.width
                    height: parent.height - 40
                    color: "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "No notifications"
                        color: Config.notificationBorderColor
                        font.pixelSize: 14
                        visible: !root.hasNotifications
                    }
                    
                    NotificationListView {
                        id: notificationListView
                        anchors.fill: parent
                        popup: false  // Show persistent notifications
                        visible: root.hasNotifications
                    }
                }
            }
        }
    }
}

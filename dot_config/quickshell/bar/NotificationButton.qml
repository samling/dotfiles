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
        
        Item {
            id: notificationContainer
            implicitWidth: notificationRow.width
            implicitHeight: 24
            
            Row {
                id: notificationRow
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Notification count (left of flag)
                Text {
                    id: countText
                    text: root.notificationCount > 99 ? "99+" : root.notificationCount.toString()
                    color: Config.notificationTextPrimaryColor
                    font.pixelSize: Config.batteryFontSize
                    font.weight: Font.Bold
                    visible: root.hasNotifications
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                // Notification flag icon
                Text {
                    id: flagIcon
                    text: root.hasNotifications ? "⚑" : "⚐"
                    font.pixelSize: 16
                    color: Config.notificationTextPrimaryColor
                    anchors.verticalCenter: parent.verticalCenter
                }
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
        
        margins.top: -1
        margins.right: 0
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
            id: notificationPanel
            anchors.top: parent.top
            anchors.right: parent.right
            width: 400
            height: Math.min(parent.height * 0.8, 600)  // Fixed height constraint
            color: Config.notificationBackgroundColor
            border.width: 0  // Remove all borders, we'll add custom ones
            
            // Only round the bottom left corner for seamless connection
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: 12
            bottomRightRadius: 0
            
            // Drop shadow
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 3
                anchors.leftMargin: 3
                color: Config.tooltipShadowColor
                opacity: Config.tooltipShadowOpacity
                topLeftRadius: 0
                topRightRadius: 0
                bottomLeftRadius: 12
                bottomRightRadius: 0
                z: -1
            }
            
            // Custom borders - only bottom and left (no top or right)
            Rectangle {
                id: bottomBorder
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 2
                color: Config.notificationBorderColor
            }
            
            Rectangle {
                id: leftBorder
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 2
                color: Config.notificationBorderColor
            }
            
            // Animation properties
            transform: Translate {
                id: slideTransform
                y: root.listOpen ? 0 : -notificationPanel.height  // Slide down from top (negative height)
                
                Behavior on y {
                    NumberAnimation {
                        duration: Config.colorAnimationDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            opacity: root.listOpen ? 1.0 : 0.0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: Config.colorAnimationDuration
                }
            }
            
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
                        popup: false  // Show persistent notifications (all notifications in the main list)
                        visible: root.hasNotifications
                    }
                }
            }
        }
    }
}

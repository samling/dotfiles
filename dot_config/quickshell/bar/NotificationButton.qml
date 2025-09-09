import qs.services
import qs.common
import qs.osd
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell

Item {
    id: root
    
    readonly property int notificationCount: Notifications.list.length
    readonly property bool hasNotifications: notificationCount > 0
    
    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    
    // Toggle notification list popup
    property bool listOpen: false
    
    Rectangle {
        id: background
        implicitWidth: rowLayout.implicitWidth + 24
        implicitHeight: rowLayout.implicitHeight + 8
        anchors.centerIn: parent
        color: mouseArea.containsMouse ? Qt.darker(Config.getColor("background.tertiary"), 1.1) : Config.getColor("background.tertiary")
        radius: height / 2
        
        Behavior on color {
            ColorAnimation {
                duration: Config.colorAnimationDuration
            }
        }
        
        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -3
            spacing: 4
            
            property int gaugeSize: Config.barHeight - Config.batteryGaugeOffset
            property color primaryColor: root.hasNotifications ? Config.clockTextColor : Config.getColor("text.muted")
            
            // Notification icon (to the left)
            Item {
                id: notificationIconContainer
                Layout.preferredWidth: rowLayout.gaugeSize * 0.8
                Layout.preferredHeight: rowLayout.gaugeSize * 0.8
                
                Text {
                    anchors.centerIn: parent
                    color: rowLayout.primaryColor
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    font.family: "DejaVu Sans Mono, Liberation Mono, Consolas, monospace"
                    textFormat: Text.PlainText
                    text: "🔔︎"
                }
            }

            // Notification count text (to the right)
            Text {
                id: countText
                Layout.alignment: Qt.AlignVCenter
                text: root.notificationCount > 99 ? "99+" : root.notificationCount.toString()
                color: rowLayout.primaryColor
                font.pixelSize: 12
                font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            root.listOpen = !root.listOpen
            // Also update GlobalStates to prevent conflicts
            GlobalStates.sidebarRightOpen = root.listOpen
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
        
        margins.top: 4
        margins.right: 4
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
            border.width: 2
            border.color: Qt.lighter(Config.notificationBackgroundColor, 1.3)
            
            // Round all corners
            topLeftRadius: 12
            topRightRadius: 12
            bottomLeftRadius: 12
            bottomRightRadius: 12
            
            // Drop shadow
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 3
                anchors.leftMargin: 3
                color: Config.tooltipShadowColor
                opacity: Config.tooltipShadowOpacity
                topLeftRadius: 12
                topRightRadius: 12
                bottomLeftRadius: 12
                bottomRightRadius: 12
                z: -1
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

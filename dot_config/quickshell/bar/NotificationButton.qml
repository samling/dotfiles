import qs.services
import qs.common
import qs.osd
import QtQuick
import QtQuick.Layouts
import Quickshell

MouseArea {
    id: root

    readonly property int notificationCount: Notifications.list.length
    readonly property bool hasNotifications: notificationCount > 0

    property int indicatorWidth: 48
    property int indicatorHeight: Config.barHeight - 16
    property int borderRadius: 4
    property int borderWidth: 1

    property color primaryColor: root.hasNotifications
        ? Config.getColor("primary.mauve")
        : Config.getColor("text.muted")

    implicitWidth: indicatorWidth
    implicitHeight: indicatorHeight
    hoverEnabled: true

    // Toggle notification list popup
    property bool listOpen: false

    onClicked: {
        root.listOpen = !root.listOpen
        GlobalStates.sidebarRightOpen = root.listOpen
    }

    // Main container with border
    Rectangle {
        id: container
        anchors.centerIn: parent
        width: root.indicatorWidth
        height: root.indicatorHeight
        radius: root.borderRadius
        color: "transparent"
        border.color: root.primaryColor
        border.width: root.borderWidth

        Behavior on border.color {
            ColorAnimation { duration: Config.colorAnimationDuration }
        }

        // Subtle fill when has notifications
        Rectangle {
            id: fillBar
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: root.borderWidth + 1
            }
            radius: Math.max(0, root.borderRadius - 2)
            color: root.hasNotifications
                ? Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.2)
                : "transparent"

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }

        // Content layout
        RowLayout {
            anchors.centerIn: parent
            spacing: 2

            // Bell icon
            Text {
                text: "🔔"
                color: root.primaryColor
                font.pixelSize: 11

                Behavior on color {
                    ColorAnimation { duration: Config.colorAnimationDuration }
                }
            }

            // Count
            Text {
                text: root.notificationCount > 99 ? "99" : root.notificationCount.toString()
                color: root.primaryColor
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.family: "monospace"

                Behavior on color {
                    ColorAnimation { duration: Config.colorAnimationDuration }
                }
            }
        }
    }

    Tooltip {
        hoverTarget: root
        text: root.hasNotifications
            ? root.notificationCount + " notification" + (root.notificationCount > 1 ? "s" : "")
            : "No notifications"
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
            width: 380
            height: Math.min(parent.height * 0.85, 550)
            color: Config.getColor("background.crust")
            border.width: 1
            border.color: Config.getColor("border.subtle")
            radius: 12

            // Animation properties
            transform: Translate {
                id: slideTransform
                y: root.listOpen ? 0 : -20

                Behavior on y {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }

            opacity: root.listOpen ? 1.0 : 0.0
            scale: root.listOpen ? 1.0 : 0.95

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            Behavior on scale {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            // Prevent clicks from passing through
            MouseArea {
                anchors.fill: parent
                onClicked: { }
            }

            Column {
                id: notificationContent
                anchors.fill: parent
                spacing: 0

                // Header bar
                Rectangle {
                    width: parent.width
                    height: 48
                    color: Config.getColor("background.mantle")
                    radius: 12

                    // Square off bottom corners
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 12
                        color: parent.color
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 12
                        spacing: 12

                        // Bell icon
                        Text {
                            text: "🔔"
                            font.pixelSize: 14
                            color: Config.getColor("primary.mauve")
                        }

                        Text {
                            text: "Notifications"
                            color: Config.getColor("text.primary")
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }

                        // Count badge
                        Rectangle {
                            visible: root.hasNotifications
                            width: countBadgeText.width + 12
                            height: 20
                            radius: 10
                            color: Config.getColor("primary.mauve")

                            Text {
                                id: countBadgeText
                                anchors.centerIn: parent
                                text: root.notificationCount > 99 ? "99+" : root.notificationCount.toString()
                                color: Config.getColor("background.crust")
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }
                        }

                        // Clear all button
                        Rectangle {
                            id: clearButton
                            width: 28
                            height: 28
                            radius: 6
                            color: clearMouseArea.containsMouse
                                ? Qt.rgba(Config.getColor("state.error").r, Config.getColor("state.error").g, Config.getColor("state.error").b, 0.2)
                                : "transparent"
                            border.color: clearMouseArea.containsMouse ? Config.getColor("state.error") : Config.getColor("border.subtle")
                            border.width: 1
                            visible: root.hasNotifications

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }

                            Behavior on border.color {
                                ColorAnimation { duration: 100 }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: clearMouseArea.containsMouse ? Config.getColor("state.error") : Config.getColor("text.muted")
                                font.pixelSize: 12
                                font.weight: Font.Bold

                                Behavior on color {
                                    ColorAnimation { duration: 100 }
                                }
                            }

                            MouseArea {
                                id: clearMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    Notifications.discardAllNotifications()
                                }
                            }

                            Tooltip {
                                hoverTarget: clearMouseArea
                                text: "Clear all"
                            }
                        }
                    }
                }

                // Divider
                Rectangle {
                    width: parent.width - 24
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Config.getColor("border.subtle")
                }

                // Notification list area
                Item {
                    width: parent.width
                    height: parent.height - 49

                    // Empty state
                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        visible: !root.hasNotifications

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "🔕"
                            font.pixelSize: 32
                            opacity: 0.5
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "All caught up!"
                            color: Config.getColor("text.muted")
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No new notifications"
                            color: Config.getColor("text.muted")
                            font.pixelSize: 11
                            opacity: 0.7
                        }
                    }

                    NotificationListView {
                        id: notificationListView
                        anchors.fill: parent
                        anchors.margins: 8
                        popup: false
                        visible: root.hasNotifications
                    }
                }
            }
        }
    }
}

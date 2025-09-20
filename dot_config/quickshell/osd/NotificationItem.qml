pragma ComponentBehavior: Bound

import qs.common
import qs.services
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var notificationObject
    property bool expanded: true
    
    implicitHeight: contentColumn.implicitHeight + 45
    radius: 12
    color: Config.notificationBackgroundColor
    border.color: Config.notificationBorderColor
    border.width: 2

    function formatTimestamp(timestamp) {
        if (!timestamp) return ""
        
        const date = new Date(timestamp)
        const now = new Date()
        
        // If it's today, just show the time
        if (date.toDateString() === now.toDateString()) {
            return Qt.formatTime(date, "h:mm AP")
        }
        // If it's this year, show month/day and time
        else if (date.getFullYear() === now.getFullYear()) {
            return Qt.formatDateTime(date, "MMM d h:mm AP")
        }
        // If it's a different year, show full date and time
        else {
            return Qt.formatDateTime(date, "MMM d yyyy h:mm AP")
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 15
        anchors.bottomMargin: 30
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // App icon
            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 16
                color: Config.notificationInactiveColor
                visible: ((appIconImage.status === Image.Ready) || (root.notificationObject?.appName !== "")) && !notificationImage.ready
                
                Image {
                    id: appIconImage
                    anchors.centerIn: parent
                    source: root.notificationObject?.appIcon ?? ""
                    fillMode: Image.PreserveAspectFit
                    width: 24
                    height: 24
                    asynchronous: true
                    cache: true
                    
                    onStatusChanged: {
                        if (status === Image.Error) {
                            console.log("[NotificationItem] Failed to load app icon:", source)
                        }
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: root.notificationObject?.appName?.charAt(0) ?? "?"
                    color: Config.notificationTextPrimaryColor
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    visible: appIconImage.status !== Image.Ready
                }
            }

            // Notification image (moved to left side of content)
            Image {
                id: notificationImage
                property bool ready: status === Image.Ready && source !== ""
                source: root.notificationObject?.image ?? ""
                visible: source !== ""
                fillMode: Image.PreserveAspectFit
                Layout.preferredWidth: Math.min(sourceSize.width, 64)
                Layout.preferredHeight: Math.min(sourceSize.height, 64)
                Layout.alignment: Qt.AlignTop
                asynchronous: true
                cache: true
                
                onStatusChanged: {
                    if (status === Image.Error) {
                        console.log("[NotificationItem] Failed to load notification image:", source)
                    } else if (status === Image.Ready) {
                        console.log("[NotificationItem] Successfully loaded notification image:", source)
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                // App name and timestamp row
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: root.notificationObject?.appName ?? ""
                        color: Config.notificationTextSecondaryColor
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        visible: text !== ""
                        Layout.fillWidth: true
                    }
                    
                    // Timestamp
                    Text {
                        text: root.formatTimestamp(root.notificationObject?.time ?? 0)
                        color: Config.notificationTextSecondaryColor
                        font.pixelSize: 12
                        font.weight: Font.Normal
                        opacity: 0.7
                        visible: root.notificationObject?.time !== undefined
                        Layout.alignment: Qt.AlignRight
                    }
                }

                // Summary (title)
                Text {
                    text: root.notificationObject?.summary ?? ""
                    color: Config.notificationTextPrimaryColor
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    visible: text !== ""
                }

                // Body text
                Text {
                    text: root.notificationObject?.body ?? ""
                    color: Config.notificationTextTertiaryColor
                    font.pixelSize: 15
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    visible: text !== ""
                    maximumLineCount: 4
                    elide: Text.ElideRight
                }
            }

            // Close button
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 12
                color: closeArea.pressed ? Config.notificationClosePressedColor : Config.notificationCloseColor
                
                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: Config.notificationBackgroundColor
                    font.pixelSize: 16
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    onClicked: {
                        Notifications.discardNotification(root.notificationObject.notificationId)
                    }
                }
            }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: root.notificationObject?.actions.length > 0

            Repeater {
                model: root.notificationObject?.actions ?? []

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 6
                    color: buttonArea.pressed ? Config.notificationButtonPressedColor : Config.notificationButtonColor
                    border.color: Config.notificationBorderColor
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: parent.modelData.text || "Action"
                        color: Config.notificationTextPrimaryColor
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: buttonArea
                        anchors.fill: parent
                        onClicked: {
                            Notifications.attemptInvokeAction(
                                root.notificationObject.notificationId, 
                                parent.modelData.identifier
                            )
                        }
                    }
                }
            }
        }
    }
}

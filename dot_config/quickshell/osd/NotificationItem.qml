import qs.common
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

Rectangle {
    id: root
    property var notificationObject
    property bool expanded: true
    
    implicitHeight: contentColumn.implicitHeight + 45
    radius: 12
    color: Config.notificationBackgroundColor
    border.color: Config.notificationBorderColor
    border.width: 2

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
                visible: root.notificationObject?.appIcon !== ""
                
                Text {
                    anchors.centerIn: parent
                    text: root.notificationObject?.appName?.charAt(0) ?? "?"
                    color: Config.notificationTextPrimaryColor
                    font.pixelSize: 16
                    font.weight: Font.Bold
                }
            }

            // Notification image (moved to left side of content)
            Image {
                source: root.notificationObject?.image ?? ""
                visible: source !== ""
                fillMode: Image.PreserveAspectFit
                Layout.preferredWidth: Math.min(sourceSize.width, 64)
                Layout.preferredHeight: Math.min(sourceSize.height, 64)
                Layout.alignment: Qt.AlignTop
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                // App name
                Text {
                    text: root.notificationObject?.appName ?? ""
                    color: Config.notificationTextSecondaryColor
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    visible: text !== ""
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
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 6
                    color: buttonArea.pressed ? Config.notificationButtonPressedColor : Config.notificationButtonColor
                    border.color: Config.notificationBorderColor
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: modelData.text || "Action"
                        color: Config.notificationTextPrimaryColor
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: buttonArea
                        anchors.fill: parent
                        onClicked: {
                            Notifications.attemptInvokeAction(
                                root.notificationObject.notificationId, 
                                modelData.identifier
                            )
                        }
                    }
                }
            }
        }
    }
}

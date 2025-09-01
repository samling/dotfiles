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
    
    implicitHeight: contentColumn.implicitHeight + 20
    radius: 12
    color: "#1e1e2e"
    border.color: "#6c7086"
    border.width: 2

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 15
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // App icon
            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 16
                color: "#45475a"
                visible: root.notificationObject?.appIcon !== ""
                
                Text {
                    anchors.centerIn: parent
                    text: root.notificationObject?.appName?.charAt(0) ?? "?"
                    color: "#cdd6f4"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                // App name
                Text {
                    text: root.notificationObject?.appName ?? ""
                    color: "#a6adc8"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    visible: text !== ""
                }

                // Summary (title)
                Text {
                    text: root.notificationObject?.summary ?? ""
                    color: "#cdd6f4"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    visible: text !== ""
                }

                // Body text
                Text {
                    text: root.notificationObject?.body ?? ""
                    color: "#bac2de"
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
                color: closeArea.pressed ? "#e64553" : "#f38ba8"
                
                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: "#1e1e2e"
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

        // Notification image
        Image {
            source: root.notificationObject?.image ?? ""
            visible: source !== ""
            fillMode: Image.PreserveAspectFit
            Layout.preferredWidth: Math.min(sourceSize.width, 300)
            Layout.preferredHeight: Math.min(sourceSize.height, 100)
            Layout.alignment: Qt.AlignHCenter
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
                    color: buttonArea.pressed ? "#585b70" : "#45475a"
                    border.color: "#6c7086"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: modelData.text || "Action"
                        color: "#cdd6f4"
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

pragma ComponentBehavior: Bound

import qs.common
import qs.services
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var notificationObject
    property bool expanded: true

    // Helper properties for image handling
    property string imgSource: notificationObject?.image ?? ""
    property bool hasImage: imgSource !== ""
    property bool isIconUrl: imgSource.startsWith("image://icon/")

    implicitHeight: contentColumn.implicitHeight + 24
    radius: 8
    color: Config.getColor("background.secondary")
    border.color: itemMouseArea.containsMouse ? Config.getColor("border.primary") : Config.getColor("border.subtle")
    border.width: 1

    Behavior on border.color {
        ColorAnimation { duration: 100 }
    }

    // Hover detection for the whole item
    MouseArea {
        id: itemMouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    function formatTimestamp(timestamp) {
        if (!timestamp) return ""

        const date = new Date(timestamp)
        const now = new Date()
        const diffMs = now - date
        const diffMins = Math.floor(diffMs / 60000)
        const diffHours = Math.floor(diffMs / 3600000)
        const diffDays = Math.floor(diffMs / 86400000)

        // Relative time for recent notifications
        if (diffMins < 1) return "Just now"
        if (diffMins < 60) return diffMins + "m ago"
        if (diffHours < 24) return diffHours + "h ago"
        if (diffDays < 7) return diffDays + "d ago"

        // Absolute time for older notifications
        if (date.getFullYear() === now.getFullYear()) {
            return Qt.formatDateTime(date, "MMM d")
        }
        return Qt.formatDateTime(date, "MMM d yyyy")
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Top row: App icon, App name, Time, Close button
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // App icon container
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 6
                color: Config.getColor("background.tertiary")
                visible: (appIconImage.status === Image.Ready) || (root.notificationObject?.appName !== "")

                Image {
                    id: appIconImage
                    anchors.centerIn: parent
                    source: root.notificationObject?.appIcon ?? ""
                    fillMode: Image.PreserveAspectFit
                    width: 18
                    height: 18
                    sourceSize.width: 18
                    sourceSize.height: 18
                    asynchronous: true
                    cache: true
                }

                // Fallback letter
                Text {
                    anchors.centerIn: parent
                    text: root.notificationObject?.appName?.charAt(0)?.toUpperCase() ?? "?"
                    color: Config.getColor("text.secondary")
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    visible: appIconImage.status !== Image.Ready
                }
            }

            // App name and timestamp
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.notificationObject?.appName ?? "Unknown"
                    color: Config.getColor("text.secondary")
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: root.formatTimestamp(root.notificationObject?.time ?? 0)
                    color: Config.getColor("text.muted")
                    font.pixelSize: 10
                    visible: root.notificationObject?.time !== undefined
                }
            }

            // Close button
            Rectangle {
                id: closeButton
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 6
                color: closeArea.containsMouse
                    ? Qt.rgba(Config.getColor("state.error").r, Config.getColor("state.error").g, Config.getColor("state.error").b, 0.2)
                    : "transparent"
                border.color: closeArea.containsMouse ? Config.getColor("state.error") : "transparent"
                border.width: 1
                opacity: itemMouseArea.containsMouse || closeArea.containsMouse ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: closeArea.containsMouse ? Config.getColor("state.error") : Config.getColor("text.muted")
                    font.pixelSize: 10
                    font.weight: Font.Bold

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Notifications.discardNotification(root.notificationObject.notificationId)
                    }
                }
            }
        }

        // Large notification image (only for actual content images, not icons/avatars)
        // Square-ish images (aspect ratio ~1:1) are treated as icons/avatars
        // Only show as large if it's clearly content (wide/landscape) and big enough
        Image {
            id: notificationImage
            property bool ready: status === Image.Ready && source !== ""
            property real aspectRatio: ready ? sourceSize.width / sourceSize.height : 1.0
            // Treat as large content image only if:
            // - Not an icon URL
            // - Large enough (>128 in both dimensions)
            // - Not square-ish (aspect ratio > 1.3, i.e., noticeably wider than tall)
            property bool isLargeImage: ready && !root.isIconUrl && sourceSize.width > 128 && sourceSize.height > 128 && aspectRatio > 1.3
            source: root.imgSource
            visible: isLargeImage
            fillMode: Image.PreserveAspectFit
            Layout.fillWidth: true
            Layout.preferredHeight: isLargeImage ? Math.min(sourceSize.height, 120) : 0
            Layout.maximumHeight: 120
            asynchronous: true
            cache: true
        }

        // Content row: Small icon (if any) + Message text
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Small notification icon (for icon URLs or small images)
            Rectangle {
                id: smallIconContainer
                // Show for icon URLs OR small images (but not if large image is shown)
                property bool showIcon: root.hasImage && (root.isIconUrl || (notificationImage.ready && !notificationImage.isLargeImage))
                visible: showIcon
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignTop
                radius: 8
                color: Config.getColor("background.tertiary")

                Image {
                    anchors.centerIn: parent
                    source: root.imgSource
                    width: 28
                    height: 28
                    sourceSize.width: 28
                    sourceSize.height: 28
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                }
            }

            // Message content
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                // Summary (title)
                Text {
                    text: root.notificationObject?.summary ?? ""
                    color: Config.getColor("text.primary")
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    visible: text !== ""
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                // Body text
                Text {
                    text: root.notificationObject?.body ?? ""
                    color: Config.getColor("text.tertiary")
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    visible: text !== ""
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    lineHeight: 1.2
                }
            }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            spacing: 6
            visible: root.notificationObject?.actions.length > 0

            Repeater {
                model: root.notificationObject?.actions ?? []

                Rectangle {
                    id: actionButton
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: 6
                    color: buttonArea.containsMouse
                        ? Config.getColor("background.surface")
                        : Config.getColor("background.tertiary")
                    border.color: buttonArea.containsMouse
                        ? Config.getColor("primary.lavender")
                        : Config.getColor("border.subtle")
                    border.width: 1

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }

                    Behavior on border.color {
                        ColorAnimation { duration: 100 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: parent.modelData.text || "Action"
                        color: buttonArea.containsMouse
                            ? Config.getColor("primary.lavender")
                            : Config.getColor("text.secondary")
                        font.pixelSize: 11
                        font.weight: Font.Medium

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }

                    MouseArea {
                        id: buttonArea
                        anchors.fill: parent
                        hoverEnabled: true
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

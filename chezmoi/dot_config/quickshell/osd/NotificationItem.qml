pragma ComponentBehavior: Bound

import qs.common
import qs.services
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property var notificationObject
    property bool expanded: true
    property bool isPopup: false
    property bool bodyExpanded: false

    // Helper properties for image handling
    property string imgSource: notificationObject?.image ?? ""
    property bool hasImage: imgSource !== ""
    property bool isIconUrl: imgSource.startsWith("image://icon/")

    // Urgency: "0" = Low, "1" = Normal, "2" = Critical
    property string urgency: notificationObject?.urgency ?? "1"
    property bool isCritical: urgency === "2"
    property bool isLow: urgency === "0"

    // Tick counter to force timestamp re-evaluation
    property int _timeRefreshTick: 0

    implicitHeight: contentColumn.implicitHeight + Style.spacing.lg * 2 + (isPopup ? progressBar.height : 0)
    radius: Style.radius.md
    color: isCritical
        ? Qt.tint(Config.getColor("background.surface"), Qt.rgba(Config.getColor("state.error").r, Config.getColor("state.error").g, Config.getColor("state.error").b, 0.25))
        : isLow
            ? Config.getColor("background.tertiary")
            : Config.getColor("background.surface")
    border.color: isCritical
        ? Config.getColor("state.error")
        : itemMouseArea.containsMouse
            ? Config.getColor("border.primary")
            : Config.getColor("border.subtle")
    border.width: 1

    Behavior on border.color {
        ColorAnimation { duration: 100 }
    }

    Behavior on color {
        ColorAnimation { duration: 100 }
    }

    // Auto-refresh timestamp every 60 seconds
    Timer {
        id: timeRefreshTimer
        interval: 60000
        running: root.visible
        repeat: true
        onTriggered: root._timeRefreshTick++
    }

    // Force timestamp refresh when becoming visible again
    onVisibleChanged: if (visible) _timeRefreshTick++

    // Hover detection for the whole item
    MouseArea {
        id: itemMouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onContainsMouseChanged: {
            if (!root.isPopup || !root.notificationObject) return
            if (containsMouse) {
                root.notificationObject.pausePopup()
                progressAnim.pause()
            } else {
                root.notificationObject.resumePopup()
                progressAnim.resume()
            }
        }
    }

    function formatTimestamp(timestamp, tick) {
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
        anchors.margins: Style.spacing.lg
        anchors.bottomMargin: isPopup ? Style.spacing.lg + progressBar.height : Style.spacing.lg
        spacing: Style.spacing.md

        // Top row: App icon, App name, Time, Close button
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacing.lg

            // App icon container
            Rectangle {
                property string resolvedIcon: Style.notificationIcon(root.notificationObject, root.imgSource)
                Layout.preferredWidth: Style.icon.notification
                Layout.preferredHeight: Style.icon.notification
                radius: Style.radius.sm
                color: root.isCritical
                    ? Qt.tint(Config.getColor("background.mantle"), Qt.rgba(Config.getColor("state.error").r, Config.getColor("state.error").g, Config.getColor("state.error").b, 0.5))
                    : Config.getColor("background.mantle")
                border.color: Config.getColor("border.subtle")
                border.width: 1
                visible: resolvedIcon !== "" || (root.notificationObject?.appName !== "")

                Image {
                    id: appIconImage
                    property bool usingImage: !root.notificationObject?.appIcon && root.hasImage
                    anchors.centerIn: parent
                    source: parent.resolvedIcon
                    fillMode: Image.PreserveAspectFit
                    width: Style.icon.app
                    height: Style.icon.app
                    sourceSize.width: Style.icon.app
                    sourceSize.height: Style.icon.app
                    asynchronous: true
                    cache: true
                }

                // Fallback letter
                Text {
                    anchors.centerIn: parent
                    text: root.notificationObject?.appName?.charAt(0)?.toUpperCase() ?? "?"
                    color: Config.getColor("text.primary")
                    font.pixelSize: Style.fontSize.medium
                    font.weight: Font.Bold
                    font.family: Config.fontFamilyMonospace
                    visible: appIconImage.status !== Image.Ready
                }
            }

            // App name and timestamp
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.spacing.md

                Text {
                    text: root.notificationObject?.appName ?? "Unknown"
                    color: Config.getColor("text.muted")
                    font.pixelSize: Style.fontSize.base
                    font.weight: Font.Medium
                    font.family: Config.fontFamilyMonospace
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: root.formatTimestamp(root.notificationObject?.time ?? 0, root._timeRefreshTick)
                    color: Config.getColor("text.muted")
                    font.pixelSize: Style.fontSize.small
                    font.family: Config.fontFamilyMonospace
                    visible: root.notificationObject?.time !== undefined
                }
            }

            // Close button
            Rectangle {
                id: closeButton
                Layout.preferredWidth: Style.icon.button
                Layout.preferredHeight: Style.icon.button
                radius: Style.radius.sm
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
                    font.pixelSize: Style.fontSize.small
                    font.weight: Font.Bold
                    font.family: Config.fontFamilyMonospace

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
            spacing: Style.spacing.lg

            // Small notification icon (for icon URLs or small images)
            Rectangle {
                id: smallIconContainer
                // Show for icon URLs OR small images (but not if large image is shown)
                property bool showIcon: root.hasImage && !appIconImage.usingImage && (root.isIconUrl || (notificationImage.ready && !notificationImage.isLargeImage))
                visible: showIcon
                Layout.preferredWidth: Style.icon.notificationContainer
                Layout.preferredHeight: Style.icon.notificationContainer
                Layout.alignment: Qt.AlignTop
                radius: Style.radius.md
                color: Style.color.surfaceRaised

                Image {
                    anchors.centerIn: parent
                    source: Style.iconSource(root.imgSource)
                    width: Style.icon.notification
                    height: Style.icon.notification
                    sourceSize.width: Style.icon.notification
                    sourceSize.height: Style.icon.notification
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                }
            }

            // Message content
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.spacing.xs

                // Summary (title)
                Text {
                    text: root.notificationObject?.summary ?? ""
                    color: Config.getColor("text.primary")
                    font.pixelSize: Style.fontSize.large
                    font.weight: Font.DemiBold
                    font.family: Config.fontFamilyMonospace
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    visible: text !== ""
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                // Body text with expand/collapse
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacing.xs
                    visible: bodyText.text !== ""

                    Text {
                        id: bodyText
                        text: root.notificationObject?.body ?? ""
                        color: Config.getColor("text.primary")
                        font.pixelSize: Style.fontSize.medium
                        font.family: Config.fontFamilyMonospace
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        maximumLineCount: root.bodyExpanded ? 0 : 1
                        elide: root.bodyExpanded ? Text.ElideNone : Text.ElideRight
                        lineHeight: 1.2
                    }

                    // Expand/collapse button (only when text is truncated or expanded)
                    Rectangle {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        Layout.alignment: Qt.AlignTop
                        radius: Style.radius.xs
                        color: expandArea.containsMouse ? Config.getColor("background.surface") : "transparent"
                        visible: bodyText.truncated || root.bodyExpanded

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: root.bodyExpanded ? "▴" : "▾"
                            color: expandArea.containsMouse ? Config.getColor("text.primary") : Config.getColor("text.muted")
                            font.pixelSize: Style.fontSize.small
                            font.family: Config.fontFamilyMonospace

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }
                        }

                        MouseArea {
                            id: expandArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.bodyExpanded = !root.bodyExpanded
                        }
                    }
                }
            }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Style.spacing.xs
            spacing: Style.spacing.sm
            visible: root.notificationObject?.actions.length > 0

            Repeater {
                model: root.notificationObject?.actions ?? []

                Rectangle {
                    id: actionButton
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: Style.radius.sm
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
                            : Config.getColor("text.primary")
                        font.pixelSize: Style.fontSize.base
                        font.weight: Font.Medium
                        font.family: Config.fontFamilyMonospace

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

    // Popup progress bar (depletes over popup duration)
    // An Item clips to a 3px tall strip; inside, tall rounded Rectangles
    // ensure the visible bottom slice follows the parent's corner curve.
    Item {
        id: progressBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.border.width
        height: root.isPopup ? 3 : 0
        clip: true
        visible: root.isPopup

        // Background track
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: (root.radius - root.border.width) * 2
            radius: root.radius - root.border.width
            color: Config.getColor("border.subtle")
            opacity: 0.3
        }

        // Progress fill
        Rectangle {
            id: progressFill
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: (root.radius - root.border.width) * 2
            radius: root.radius - root.border.width
            color: root.isCritical ? Config.getColor("state.error") : Config.getColor("primary.lavender")

            transform: Scale {
                id: progressScale
                origin.x: 0
                xScale: 1.0
            }

            NumberAnimation {
                id: progressAnim
                target: progressScale
                property: "xScale"
                from: 1.0
                to: 0.0
                duration: root.notificationObject?.popupDuration ?? 5000
                running: root.isPopup
            }
        }
    }
}

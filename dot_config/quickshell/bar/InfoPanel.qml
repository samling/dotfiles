pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import qs.common
import qs.services
import qs.osd

Item {
    id: root

    property var cpuIndicator
    property var memIndicator
    property var diskIndicator

    property bool panelOpen: GlobalStates.sidebarRightOpen

    readonly property int notificationCount: Notifications.list.length
    readonly property bool hasNotifications: notificationCount > 0

    property bool expandAllState: true
    property bool notificationsExpanded: false
    property string activeSubPanel: ""
    property int _timeRefreshTick: 0
    property bool sinkDropdownOpen: false
    property bool sourceDropdownOpen: false
    signal toggleExpandAll()

    // Auto-refresh notification timestamps every 60 seconds
    Timer {
        interval: 60000
        running: root.panelOpen
        repeat: true
        onTriggered: root._timeRefreshTick++
    }

    onPanelOpenChanged: {
        if (panelOpen) {
            _timeRefreshTick++
        } else {
            activeSubPanel = ""
            sinkDropdownOpen = false
            sourceDropdownOpen = false
        }
    }

    PanelWindow {
        id: panelWindow
        visible: root.panelOpen || slideAnim.running

        WlrLayershell.namespace: "quickshell:infopanel"
        WlrLayershell.layer: root.panelOpen || slideAnim.running ? WlrLayer.Top : WlrLayer.Background
        exclusiveZone: 0

        anchors {
            top: true
            right: true
            bottom: true
        }

        margins.top: 4
        margins.right: 4
        margins.bottom: 4

        implicitWidth: 388
        color: "transparent"

        HyprlandFocusGrab {
            id: focusGrab
            active: root.panelOpen
            windows: [panelWindow]
            onCleared: GlobalStates.sidebarRightOpen = false
        }

        // The panel
        Rectangle {
            id: panel
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: root.panelOpen ? 0 : -width - 20
            width: parent.width
            color: Config.getColor("background.crust")
            border.width: 1
            border.color: Config.getColor("border.subtle")
            radius: 12
            clip: true

            Behavior on anchors.rightMargin {
                NumberAnimation {
                    id: slideAnim
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // ── Header ──
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
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

                        Text {
                            text: "\uf0e4"
                            font.pixelSize: Config.fontSizeHeader
                            font.family: Config.fontFamilyIcon
                            color: Config.getColor("primary.blue")
                        }

                        Text {
                            text: "System"
                            color: Config.getColor("text.primary")
                            font.pixelSize: Config.fontSizeHeader
                            font.weight: Font.DemiBold
                            font.family: Config.fontFamilyMonospace
                            Layout.fillWidth: true
                        }

                        // Close button
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 6
                            color: closeMouse.containsMouse
                                ? Qt.rgba(Config.getColor("state.error").r, Config.getColor("state.error").g, Config.getColor("state.error").b, 0.2)
                                : "transparent"
                            border.color: closeMouse.containsMouse ? Config.getColor("state.error") : Config.getColor("border.subtle")
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 100 } }
                            Behavior on border.color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: closeMouse.containsMouse ? Config.getColor("state.error") : Config.getColor("text.muted")
                                font.pixelSize: Config.fontSizeMedium
                                font.weight: Font.Bold
                                font.family: Config.fontFamilyMonospace

                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: GlobalStates.sidebarRightOpen = false
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.preferredHeight: 1
                    color: Config.getColor("border.subtle")
                    visible: root.activeSubPanel === ""
                }

                // ── Notifications Section ──
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.activeSubPanel === ""

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Notification section header
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            Layout.topMargin: 8
                            Layout.bottomMargin: 4
                            spacing: 8

                            Text {
                                text: "🔔\uFE0E"
                                font.pixelSize: Config.fontSizeMedium
                                color: Config.getColor("primary.mauve")
                            }

                            Text {
                                text: "Notifications"
                                color: Config.getColor("text.secondary")
                                font.pixelSize: Config.fontSizeMedium
                                font.weight: Font.DemiBold
                                font.family: Config.fontFamilyMonospace
                                Layout.fillWidth: true
                            }

                            // Count badge
                            Rectangle {
                                visible: root.hasNotifications
                                width: badgeText.width + 10
                                height: 18
                                radius: 9
                                color: Config.getColor("primary.mauve")

                                Text {
                                    id: badgeText
                                    anchors.centerIn: parent
                                    text: root.notificationCount > 99 ? "99+" : root.notificationCount.toString()
                                    color: Config.getColor("background.crust")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }

                            // Expand/collapse all
                            Rectangle {
                                width: 22
                                height: 22
                                radius: 6
                                visible: root.hasNotifications
                                color: expandAllMouse.containsMouse
                                    ? Config.getColor("background.tertiary")
                                    : "transparent"
                                border.color: expandAllMouse.containsMouse ? Config.getColor("border.primary") : Config.getColor("border.subtle")
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 100 } }
                                Behavior on border.color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: root.expandAllState ? "\uf066" : "\uf065"
                                    color: expandAllMouse.containsMouse ? Config.getColor("text.primary") : Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyIcon

                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    id: expandAllMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        root.expandAllState = !root.expandAllState
                                        root.toggleExpandAll()
                                    }
                                }
                            }

                            // Maximize/restore notifications
                            Rectangle {
                                width: 22
                                height: 22
                                radius: 6
                                visible: root.hasNotifications
                                color: maximizeMouse.containsMouse
                                    ? Config.getColor("background.tertiary")
                                    : "transparent"
                                border.color: maximizeMouse.containsMouse ? Config.getColor("border.primary") : Config.getColor("border.subtle")
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 100 } }
                                Behavior on border.color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: root.notificationsExpanded ? "\uf2d2" : "\uf2d0"
                                    color: maximizeMouse.containsMouse ? Config.getColor("text.primary") : Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyIcon

                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    id: maximizeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.notificationsExpanded = !root.notificationsExpanded
                                }
                            }

                            // Clear all
                            Rectangle {
                                width: 22
                                height: 22
                                radius: 6
                                visible: root.hasNotifications
                                color: clearAllMouse.containsMouse
                                    ? Qt.rgba(Config.getColor("state.error").r, Config.getColor("state.error").g, Config.getColor("state.error").b, 0.2)
                                    : "transparent"
                                border.color: clearAllMouse.containsMouse ? Config.getColor("state.error") : Config.getColor("border.subtle")
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 100 } }
                                Behavior on border.color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: clearAllMouse.containsMouse ? Config.getColor("state.error") : Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace

                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    id: clearAllMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: Notifications.discardAllNotifications()
                                }
                            }
                        }

                        // Notification list (condensed rows)
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 8
                            Layout.rightMargin: 8

                            // Empty state
                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                visible: !root.hasNotifications

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "󰂛"
                                    font.pixelSize: Config.fontSizeIconLarge
                                    font.family: Config.fontFamilyIcon
                                    color: Config.getColor("text.muted")
                                    opacity: 0.5
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "No notifications"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeMedium
                                    font.family: Config.fontFamilyMonospace
                                }
                            }

                            // Condensed notification list
                            ListView {
                                id: notifList
                                anchors.fill: parent
                                clip: true
                                spacing: 2
                                visible: root.hasNotifications
                                boundsBehavior: Flickable.DragAndOvershootBounds
                                boundsMovement: Flickable.FollowBoundsBehavior

                                ScrollBar.vertical: ScrollBar {
                                    id: notifScrollBar
                                    policy: ScrollBar.AsNeeded

                                    contentItem: Rectangle {
                                        implicitWidth: 3
                                        radius: 1.5
                                        color: notifScrollBar.pressed
                                            ? Config.getColor("text.muted")
                                            : Config.getColor("border.subtle")
                                        opacity: notifScrollBar.active ? 1.0 : 0.0

                                        Behavior on opacity { NumberAnimation { duration: 150 } }
                                    }

                                    background: Rectangle {
                                        implicitWidth: 3
                                        color: "transparent"
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    propagateComposedEvents: true
                                    acceptedButtons: Qt.NoButton

                                    onWheel: (wheel) => {
                                        const scrollDistance = wheel.angleDelta.y * 2
                                        notifList.contentY = Math.max(0,
                                            Math.min(notifList.contentY - scrollDistance,
                                                     notifList.contentHeight - notifList.height))
                                        wheel.accepted = true
                                    }

                                    onPressed: (mouse) => { mouse.accepted = false }
                                }

                                model: ScriptModel {
                                    values: Notifications.list.slice().reverse()
                                }

                                delegate: Rectangle {
                                    id: notifRow
                                    required property var modelData
                                    required property int index
                                    width: notifList.width - 6
                                    height: notifColumn.implicitHeight + 8
                                    radius: 6
                                    property bool hovered: notifRowMouse.containsMouse || dismissMouse.containsMouse
                                    color: hovered
                                        ? Config.getColor("background.tertiary")
                                        : notifRow.expanded
                                            ? Config.getColor("background.secondary")
                                            : "transparent"

                                    property bool expanded: root.expandAllState

                                    Connections {
                                        target: root
                                        function onToggleExpandAll() {
                                            notifRow.expanded = root.expandAllState
                                        }
                                    }

                                    Behavior on height {
                                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                    }

                                    Behavior on color { ColorAnimation { duration: 100 } }

                                    MouseArea {
                                        id: notifRowMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: notifRow.expanded = !notifRow.expanded
                                    }

                                    Column {
                                        id: notifColumn
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.margins: 4
                                        anchors.leftMargin: 6
                                        anchors.rightMargin: 6
                                        spacing: 4

                                        // Compact header row (always visible)
                                        RowLayout {
                                            width: parent.width
                                            spacing: 6

                                            // App icon/letter — prefer notification image (sender avatar), fall back to app icon, then letter
                                            Rectangle {
                                                Layout.preferredWidth: 20
                                                Layout.preferredHeight: 20
                                                radius: 4
                                                color: Config.getColor("background.tertiary")
                                                clip: true

                                                Image {
                                                    id: rowNotifImage
                                                    anchors.centerIn: parent
                                                    source: notifRow.modelData?.image ?? ""
                                                    width: 18
                                                    height: 18
                                                    sourceSize.width: 18
                                                    sourceSize.height: 18
                                                    fillMode: Image.PreserveAspectCrop
                                                    asynchronous: true
                                                    cache: true
                                                    visible: status === Image.Ready && source !== ""
                                                }

                                                Image {
                                                    id: rowAppIcon
                                                    anchors.centerIn: parent
                                                    property string rawIcon: notifRow.modelData?.appIcon ?? ""
                                                    source: {
                                                        if (rawIcon === "") return ""
                                                        if (rawIcon.startsWith("image://") || rawIcon.startsWith("/") || rawIcon.startsWith("file://"))
                                                            return rawIcon
                                                        return "image://icon/" + rawIcon
                                                    }
                                                    width: 14
                                                    height: 14
                                                    sourceSize.width: 14
                                                    sourceSize.height: 14
                                                    fillMode: Image.PreserveAspectFit
                                                    asynchronous: true
                                                    cache: true
                                                    visible: !rowNotifImage.visible && status === Image.Ready && source !== ""
                                                }

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: notifRow.modelData?.appName?.charAt(0)?.toUpperCase() ?? "?"
                                                    color: Config.getColor("text.secondary")
                                                    font.pixelSize: Config.fontSizeSmall
                                                    font.weight: Font.Bold
                                                    font.family: Config.fontFamilyMonospace
                                                    visible: !rowNotifImage.visible && rowAppIcon.status !== Image.Ready
                                                }
                                            }

                                            // Summary
                                            Text {
                                                text: notifRow.modelData?.summary ?? notifRow.modelData?.appName ?? ""
                                                color: Config.getColor("text.primary")
                                                font.pixelSize: Config.fontSizeBase
                                                font.weight: Font.Medium
                                                font.family: Config.fontFamilyMonospace
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                                maximumLineCount: 1
                                            }

                                            // Time
                                            Text {
                                                text: {
                                                    void root._timeRefreshTick // force re-evaluation on tick
                                                    const t = notifRow.modelData?.time
                                                    if (!t) return ""
                                                    const diff = Math.floor((Date.now() - t) / 60000)
                                                    if (diff < 1) return "now"
                                                    if (diff < 60) return diff + "m"
                                                    const h = Math.floor(diff / 60)
                                                    if (h < 24) return h + "h"
                                                    return Math.floor(h / 24) + "d"
                                                }
                                                color: Config.getColor("text.muted")
                                                font.pixelSize: Config.fontSizeSmall
                                                font.family: Config.fontFamilyMonospace
                                            }

                                            // Dismiss
                                            Rectangle {
                                                Layout.preferredWidth: 18
                                                Layout.preferredHeight: 18
                                                radius: 4
                                                color: dismissMouse.containsMouse
                                                    ? Config.getColor("state.error")
                                                    : "transparent"
                                                opacity: notifRow.hovered || notifRow.expanded ? 1.0 : 0.0

                                                Behavior on opacity { NumberAnimation { duration: 100 } }
                                                Behavior on color { ColorAnimation { duration: 100 } }

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "✕"
                                                    color: dismissMouse.containsMouse ? Config.getColor("background.crust") : Config.getColor("text.muted")
                                                    font.pixelSize: 8
                                                    font.weight: Font.Bold
                                                    font.family: Config.fontFamilyMonospace

                                                    Behavior on color { ColorAnimation { duration: 100 } }
                                                }

                                                MouseArea {
                                                    id: dismissMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: Notifications.discardNotification(notifRow.modelData.notificationId)
                                                }
                                            }
                                        }

                                        // Expanded body (click to show)
                                        Column {
                                            width: parent.width
                                            spacing: 4
                                            visible: notifRow.expanded
                                            clip: true

                                            // App name
                                            Text {
                                                text: notifRow.modelData?.appName ?? ""
                                                color: Config.getColor("text.muted")
                                                font.pixelSize: Config.fontSizeSmall
                                                font.family: Config.fontFamilyMonospace
                                                visible: text !== "" && text !== (notifRow.modelData?.summary ?? "")
                                            }

                                            // Body text
                                            Text {
                                                text: notifRow.modelData?.body ?? ""
                                                color: Config.getColor("text.secondary")
                                                font.pixelSize: Config.fontSizeBase
                                                font.family: Config.fontFamilyMonospace
                                                wrapMode: Text.WordWrap
                                                width: parent.width
                                                visible: text !== ""
                                                lineHeight: 1.3
                                            }

                                        }
                                    }
                                }

                                add: Transition {
                                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
                                }

                                remove: Transition {
                                    NumberAnimation { property: "opacity"; to: 0; duration: 100 }
                                }

                                displaced: Transition {
                                    NumberAnimation { properties: "y"; duration: 150; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 12
                    Layout.rightMargin: 12
                    Layout.preferredHeight: 1
                    color: Config.getColor("border.subtle")
                    visible: !root.notificationsExpanded
                }

                // ── System Section ──
                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    contentHeight: systemSection.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    visible: !root.notificationsExpanded && root.activeSubPanel === ""

                    Column {
                        id: systemSection
                        width: parent.width
                        spacing: 8
                        padding: 12

                        // ── Quick Toggles Grid ──
                        Grid {
                            width: parent.width - 24
                            columns: 2
                            spacing: 6

                            ToggleButton {
                                width: (parent.width - parent.spacing) / 2
                                icon: "\uf1eb"
                                label: "WiFi"
                                status: Wifi.connected ? Wifi.ssid : (Wifi.enabled ? "Disconnected" : "Off")
                                active: Wifi.connected
                                accentColor: Config.getColor("primary.blue")
                                onClicked: Wifi.toggle()
                                onExpandClicked: root.activeSubPanel = "wifi"
                            }

                            ToggleButton {
                                width: (parent.width - parent.spacing) / 2
                                icon: "\uf294"
                                label: "Bluetooth"
                                status: {
                                    if (!BluetoothService.available) return "Unavailable"
                                    if (!BluetoothService.enabled) return "Off"
                                    if (BluetoothService.connectedCount > 0)
                                        return BluetoothService.connectedCount + " connected"
                                    return "On"
                                }
                                active: BluetoothService.enabled
                                accentColor: Config.getColor("primary.blue")
                                onClicked: BluetoothService.toggle()
                                onExpandClicked: root.activeSubPanel = "bluetooth"
                            }
                        }

                        // ── Brightness Slider ──
                        RowLayout {
                            width: parent.width - 24
                            spacing: 8
                            visible: Brightness.available

                            Text {
                                text: Brightness.brightnessPercent > 50 ? "\uf185" : "\uf186"
                                font.pixelSize: Config.fontSizeSmall
                                font.family: Config.fontFamilyIcon
                                color: Config.getColor("text.muted")
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 6
                                radius: 3
                                color: Config.getColor("background.secondary")

                                Rectangle {
                                    width: parent.width * (Brightness.brightnessPercent / 100)
                                    height: parent.height
                                    radius: parent.radius
                                    color: Config.getColor("primary.yellow")

                                    Behavior on width { NumberAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    onClicked: (mouse) => {
                                        const percent = Math.round((mouse.x / parent.width) * 100)
                                        Brightness.setBrightnessPercent(percent)
                                    }
                                    onPositionChanged: (mouse) => {
                                        if (pressed) {
                                            const percent = Math.max(1, Math.min(100, Math.round((mouse.x / parent.width) * 100)))
                                            Brightness.setBrightnessPercent(percent)
                                        }
                                    }
                                }
                            }

                            Text {
                                text: Math.round(Brightness.brightnessPercent) + "%"
                                color: Config.getColor("text.muted")
                                font.pixelSize: Config.fontSizeSmall - 1
                                font.family: Config.fontFamilyMonospace
                                Layout.preferredWidth: 30
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        // ── Volume Slider ──
                        RowLayout {
                            width: parent.width - 24
                            spacing: 8
                            visible: Volume.available

                            Text {
                                text: Volume.mutedState ? "󰖁" : (Volume.percentage > 0.5 ? "󰕾" : "󰖀")
                                font.pixelSize: Config.fontSizeSmall
                                font.family: Config.fontFamilyIcon
                                color: Volume.mutedState ? Config.getColor("state.error") : Config.getColor("text.muted")

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    onClicked: {
                                        if (Pipewire.defaultAudioSink?.audio)
                                            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 6
                                radius: 3
                                color: Config.getColor("background.secondary")

                                Rectangle {
                                    width: parent.width * Math.min(Volume.percentage, 1.0)
                                    height: parent.height
                                    radius: parent.radius
                                    color: Volume.mutedState
                                        ? Config.getColor("text.muted")
                                        : Config.getColor("primary.blue")

                                    Behavior on width { NumberAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    onClicked: (mouse) => {
                                        if (Pipewire.defaultAudioSink?.audio) {
                                            Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1.0, mouse.x / parent.width))
                                        }
                                    }
                                    onPositionChanged: (mouse) => {
                                        if (pressed && Pipewire.defaultAudioSink?.audio) {
                                            Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1.0, mouse.x / parent.width))
                                        }
                                    }
                                }
                            }

                            Text {
                                text: Volume.mutedState ? "Muted" : Math.round(Volume.percentage * 100) + "%"
                                color: Config.getColor("text.muted")
                                font.pixelSize: Config.fontSizeSmall - 1
                                font.family: Config.fontFamilyMonospace
                                Layout.preferredWidth: 36
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        // ── Audio Output Device ──
                        Item {
                            width: parent.width - 24
                            height: sinkSelectorCol.implicitHeight
                            visible: Volume.sinkNodes.length > 0

                            Column {
                                id: sinkSelectorCol
                                width: parent.width
                                spacing: 4

                                Text {
                                    text: "Output Device"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }

                                Rectangle {
                                    id: sinkSelector
                                    width: parent.width
                                    height: 32
                                    radius: 6
                                    color: sinkSelectorMouse.containsMouse
                                        ? Config.getColor("background.tertiary")
                                        : Config.getColor("background.secondary")
                                    border.color: root.sinkDropdownOpen
                                        ? Config.getColor("primary.blue")
                                        : sinkSelectorMouse.containsMouse
                                            ? Config.getColor("border.primary")
                                            : Config.getColor("border.subtle")
                                    border.width: 1

                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    Behavior on border.color { ColorAnimation { duration: 100 } }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 6

                                        Text {
                                            text: "󰕾"
                                            font.pixelSize: Config.fontSizeBase
                                            font.family: Config.fontFamilyIcon
                                            color: Config.getColor("text.secondary")
                                        }

                                        Text {
                                            text: Volume.deviceName || "No device"
                                            color: Config.getColor("text.primary")
                                            font.pixelSize: Config.fontSizeSmall
                                            font.family: Config.fontFamilyMonospace
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: root.sinkDropdownOpen ? "\uf077" : "\uf078"
                                            font.pixelSize: Config.fontSizeSmall
                                            font.family: Config.fontFamilyIcon
                                            color: Config.getColor("text.muted")
                                        }
                                    }

                                    MouseArea {
                                        id: sinkSelectorMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            root.sourceDropdownOpen = false
                                            if (!root.sinkDropdownOpen) {
                                                const pos = sinkSelector.mapToItem(panel, 0, sinkSelector.height + 2)
                                                sinkDropdownPopup.x = pos.x
                                                sinkDropdownPopup.y = pos.y
                                            }
                                            root.sinkDropdownOpen = !root.sinkDropdownOpen
                                        }
                                    }
                                }
                            }

                        }

                        // ── Audio Input Device ──
                        Item {
                            width: parent.width - 24
                            height: sourceSelectorCol.implicitHeight
                            visible: Volume.sourceNodes.length > 0

                            Column {
                                id: sourceSelectorCol
                                width: parent.width
                                spacing: 4

                                Text {
                                    text: "Input Device"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }

                                Rectangle {
                                    id: sourceSelector
                                    width: parent.width
                                    height: 32
                                    radius: 6
                                    color: sourceSelectorMouse.containsMouse
                                        ? Config.getColor("background.tertiary")
                                        : Config.getColor("background.secondary")
                                    border.color: root.sourceDropdownOpen
                                        ? Config.getColor("primary.blue")
                                        : sourceSelectorMouse.containsMouse
                                            ? Config.getColor("border.primary")
                                            : Config.getColor("border.subtle")
                                    border.width: 1

                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    Behavior on border.color { ColorAnimation { duration: 100 } }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 6

                                        Text {
                                            text: "\uf130"
                                            font.pixelSize: Config.fontSizeBase
                                            font.family: Config.fontFamilyIcon
                                            color: Config.getColor("text.secondary")
                                        }

                                        Text {
                                            text: Volume.sourceName || "No device"
                                            color: Config.getColor("text.primary")
                                            font.pixelSize: Config.fontSizeSmall
                                            font.family: Config.fontFamilyMonospace
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: root.sourceDropdownOpen ? "\uf077" : "\uf078"
                                            font.pixelSize: Config.fontSizeSmall
                                            font.family: Config.fontFamilyIcon
                                            color: Config.getColor("text.muted")
                                        }
                                    }

                                    MouseArea {
                                        id: sourceSelectorMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            root.sinkDropdownOpen = false
                                            if (!root.sourceDropdownOpen) {
                                                const pos = sourceSelector.mapToItem(panel, 0, sourceSelector.height + 2)
                                                sourceDropdownPopup.x = pos.x
                                                sourceDropdownPopup.y = pos.y
                                            }
                                            root.sourceDropdownOpen = !root.sourceDropdownOpen
                                        }
                                    }
                                }
                            }

                        }

                        // ── Separator ──
                        Rectangle {
                            width: parent.width - 24
                            height: 1
                            color: Config.getColor("border.subtle")
                        }

                        // Section header
                        RowLayout {
                            width: parent.width - 24
                            spacing: 8

                            Text {
                                text: "\uf2db"
                                font.pixelSize: Config.fontSizeMedium
                                font.family: Config.fontFamilyIcon
                                color: Config.getColor("primary.blue")
                            }

                            Text {
                                text: "CPU"
                                color: Config.getColor("text.secondary")
                                font.pixelSize: Config.fontSizeMedium
                                font.weight: Font.DemiBold
                                font.family: Config.fontFamilyMonospace
                                Layout.fillWidth: true
                            }
                        }

                        // Stats row
                        RowLayout {
                            width: parent.width - 24
                            spacing: 16

                            Column {
                                spacing: 2
                                Text {
                                    text: "Usage"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }
                                Text {
                                    text: root.cpuIndicator ? Math.round(root.cpuIndicator.cpuUsage * 100) + "%" : "—"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeLarge
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }

                            Column {
                                spacing: 2
                                Text {
                                    text: "Temp"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }
                                Text {
                                    text: root.cpuIndicator && root.cpuIndicator.cpuTemp > 0 ? root.cpuIndicator.cpuTemp + "°C" : "—"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeLarge
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }

                            Column {
                                spacing: 2
                                Text {
                                    text: "Fan"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }
                                Text {
                                    text: root.cpuIndicator ? root.cpuIndicator.fanState : "—"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeLarge
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }
                        }

                        // Power Profile toggle
                        Column {
                            width: parent.width - 24
                            spacing: 4

                            Text {
                                text: "Power Profile"
                                color: Config.getColor("text.muted")
                                font.pixelSize: Config.fontSizeSmall
                                font.family: Config.fontFamilyMonospace
                            }

                            Row {
                                spacing: 4

                                Repeater {
                                    model: root.cpuIndicator ? root.cpuIndicator.powerProfileModes : []

                                    Rectangle {
                                        required property var modelData
                                        property bool isActive: root.cpuIndicator && root.cpuIndicator.powerProfile === modelData.value
                                        width: (systemSection.width - 24 - 8) / 3
                                        height: 32
                                        radius: 6
                                        color: isActive
                                            ? Qt.rgba(Config.getColor("primary.blue").r, Config.getColor("primary.blue").g, Config.getColor("primary.blue").b, 0.2)
                                            : profileMouse.containsMouse
                                                ? Config.getColor("background.tertiary")
                                                : Config.getColor("background.secondary")
                                        border.width: isActive ? 1 : 0
                                        border.color: Config.getColor("primary.blue")

                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: modelData.icon
                                                font.pixelSize: Config.fontSizeBase
                                                font.family: Config.fontFamilyIcon
                                                color: parent.parent.isActive
                                                    ? Config.getColor("primary.blue")
                                                    : Config.getColor("text.secondary")
                                            }

                                            Text {
                                                text: modelData.label
                                                font.pixelSize: Config.fontSizeSmall
                                                font.weight: parent.parent.isActive ? Font.Bold : Font.Medium
                                                font.family: Config.fontFamilyMonospace
                                                color: parent.parent.isActive
                                                    ? Config.getColor("primary.blue")
                                                    : Config.getColor("text.primary")
                                            }
                                        }

                                        MouseArea {
                                            id: profileMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                if (root.cpuIndicator)
                                                    root.cpuIndicator.setPowerProfile(modelData.value)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Fan mode toggle
                        Column {
                            width: parent.width - 24
                            spacing: 4

                            Text {
                                text: "Fan Mode"
                                color: Config.getColor("text.muted")
                                font.pixelSize: Config.fontSizeSmall
                                font.family: Config.fontFamilyMonospace
                            }

                            Row {
                                spacing: 4

                                Repeater {
                                    model: root.cpuIndicator ? root.cpuIndicator.fanModes : []

                                    Rectangle {
                                        required property var modelData
                                        property bool isActive: root.cpuIndicator && root.cpuIndicator.fanState.toLowerCase().indexOf(modelData.label.toLowerCase()) !== -1
                                        width: (systemSection.width - 24 - 12) / 4
                                        height: 32
                                        radius: 6
                                        color: isActive
                                            ? Qt.rgba(Config.getColor("primary.blue").r, Config.getColor("primary.blue").g, Config.getColor("primary.blue").b, 0.2)
                                            : fanMouse.containsMouse
                                                ? Config.getColor("background.tertiary")
                                                : Config.getColor("background.secondary")
                                        border.width: isActive ? 1 : 0
                                        border.color: Config.getColor("primary.blue")

                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 1

                                            Text {
                                                text: modelData.icon
                                                font.pixelSize: Config.fontSizeBase
                                                font.family: Config.fontFamilyIcon
                                                Layout.alignment: Qt.AlignHCenter
                                                color: parent.parent.isActive
                                                    ? Config.getColor("primary.blue")
                                                    : Config.getColor("text.secondary")
                                            }

                                            Text {
                                                text: modelData.label
                                                font.pixelSize: 9
                                                font.weight: parent.parent.isActive ? Font.Bold : Font.Medium
                                                font.family: Config.fontFamilyMonospace
                                                Layout.alignment: Qt.AlignHCenter
                                                color: parent.parent.isActive
                                                    ? Config.getColor("primary.blue")
                                                    : Config.getColor("text.primary")
                                            }
                                        }

                                        MouseArea {
                                            id: fanMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                if (root.cpuIndicator)
                                                    root.cpuIndicator.setFanState(modelData.value)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ── Separator ──
                        Rectangle {
                            width: parent.width - 24
                            height: 1
                            color: Config.getColor("border.subtle")
                        }

                        // ── Memory Section ──
                        RowLayout {
                            width: parent.width - 24
                            spacing: 8

                            Text {
                                text: "\uf538"
                                font.pixelSize: Config.fontSizeMedium
                                font.family: Config.fontFamilyIcon
                                color: Config.getColor("primary.mauve")
                            }

                            Text {
                                text: "Memory"
                                color: Config.getColor("text.secondary")
                                font.pixelSize: Config.fontSizeMedium
                                font.weight: Font.DemiBold
                                font.family: Config.fontFamilyMonospace
                                Layout.fillWidth: true
                            }
                        }

                        // Memory stats
                        RowLayout {
                            width: parent.width - 24
                            spacing: 16

                            Column {
                                spacing: 2
                                Text {
                                    text: "Usage"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }
                                Text {
                                    text: root.memIndicator ? Math.round(root.memIndicator.memUsage * 100) + "%" : "—"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeLarge
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }

                            Column {
                                spacing: 2
                                Text {
                                    text: "Used"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }
                                Text {
                                    text: root.memIndicator ? (root.memIndicator.memUsed / 1048576).toFixed(1) + "G" : "—"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeLarge
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }

                            Column {
                                spacing: 2
                                Text {
                                    text: "Total"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }
                                Text {
                                    text: root.memIndicator ? (root.memIndicator.memTotal / 1048576).toFixed(1) + "G" : "—"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeLarge
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }
                        }

                        // ── Separator ──
                        Rectangle {
                            width: parent.width - 24
                            height: 1
                            color: Config.getColor("border.subtle")
                        }

                        // ── Disk Section ──
                        RowLayout {
                            width: parent.width - 24
                            spacing: 8

                            Text {
                                text: "\uf0a0"
                                font.pixelSize: Config.fontSizeMedium
                                font.family: Config.fontFamilyIcon
                                color: Config.getColor("primary.teal")
                            }

                            Text {
                                text: "Disk (" + (root.diskIndicator ? root.diskIndicator.mountPoint : "/") + ")"
                                color: Config.getColor("text.secondary")
                                font.pixelSize: Config.fontSizeMedium
                                font.weight: Font.DemiBold
                                font.family: Config.fontFamilyMonospace
                                Layout.fillWidth: true
                            }
                        }

                        // Disk stats row
                        RowLayout {
                            width: parent.width - 24
                            spacing: 16

                            Column {
                                spacing: 2
                                Text {
                                    text: "Used"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }
                                Text {
                                    text: root.diskIndicator ? root.diskIndicator.diskUsed : "—"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeLarge
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }

                            Column {
                                spacing: 2
                                Text {
                                    text: "Total"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }
                                Text {
                                    text: root.diskIndicator ? root.diskIndicator.diskTotal : "—"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeLarge
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }

                            Column {
                                spacing: 2
                                Text {
                                    text: "Free"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }
                                Text {
                                    text: root.diskIndicator ? root.diskIndicator.diskAvail : "—"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeLarge
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }
                        }

                        // Disk usage bar
                        Column {
                            width: parent.width - 24
                            spacing: 4

                            Rectangle {
                                width: parent.width
                                height: 16
                                radius: 4
                                color: Config.getColor("background.secondary")
                                clip: true

                                Rectangle {
                                    id: diskBar
                                    width: parent.width * (root.diskIndicator ? root.diskIndicator.diskUsage : 0)
                                    height: parent.height
                                    radius: 4
                                    color: {
                                        if (!root.diskIndicator) return Config.getColor("primary.teal")
                                        const usage = root.diskIndicator.diskUsage
                                        if (usage > 0.9) return Config.getColor("state.error")
                                        if (usage > 0.75) return Config.getColor("state.warning")
                                        return Config.getColor("primary.teal")
                                    }

                                    Behavior on width {
                                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                                    }

                                    Behavior on color {
                                        ColorAnimation { duration: 300 }
                                    }
                                }

                                // Percentage label centered on the bar
                                Text {
                                    anchors.centerIn: parent
                                    text: root.diskIndicator ? Math.round(root.diskIndicator.diskUsage * 100) + "%" : "—"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.weight: Font.Bold
                                    font.family: Config.fontFamilyMonospace
                                }
                            }
                        }
                    }
                }

            }

            // ── Audio dropdown overlays (outside Flickable to avoid clipping) ──
            Rectangle {
                id: sinkDropdownPopup
                width: sinkSelector.width
                height: root.sinkDropdownOpen ? sinkDropdownColumn.implicitHeight + 8 : 0
                clip: true
                z: 20
                visible: height > 0 || sinkDropdownAnim.running
                radius: 6
                color: Config.getColor("background.mantle")
                border.color: Config.getColor("border.subtle")
                border.width: 1

                Behavior on height {
                    NumberAnimation {
                        id: sinkDropdownAnim
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Column {
                    id: sinkDropdownColumn
                    width: parent.width
                    anchors.top: parent.top
                    anchors.margins: 4
                    spacing: 1

                    Repeater {
                        model: Volume.sinkNodes

                        Rectangle {
                            required property var modelData
                            property bool isActive: Pipewire.defaultAudioSink && modelData.name === Pipewire.defaultAudioSink.name
                            width: sinkDropdownColumn.width
                            height: 30
                            radius: 4
                            color: isActive
                                ? Qt.rgba(Config.getColor("primary.blue").r, Config.getColor("primary.blue").g, Config.getColor("primary.blue").b, 0.15)
                                : sinkItemMouse.containsMouse
                                    ? Config.getColor("background.tertiary")
                                    : "transparent"

                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                Text {
                                    text: parent.parent.isActive ? "\uf058" : "\uf111"
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyIcon
                                    color: parent.parent.isActive
                                        ? Config.getColor("primary.blue")
                                        : Config.getColor("text.muted")
                                }

                                Text {
                                    text: modelData.description || modelData.name || "Unknown"
                                    color: parent.parent.isActive
                                        ? Config.getColor("primary.blue")
                                        : Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.weight: parent.parent.isActive ? Font.Bold : Font.Normal
                                    font.family: Config.fontFamilyMonospace
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            MouseArea {
                                id: sinkItemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    Volume.setDefaultSink(modelData)
                                    root.sinkDropdownOpen = false
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: sourceDropdownPopup
                width: sourceSelector.width
                height: root.sourceDropdownOpen ? sourceDropdownColumn.implicitHeight + 8 : 0
                clip: true
                z: 20
                visible: height > 0 || sourceDropdownAnim.running
                radius: 6
                color: Config.getColor("background.mantle")
                border.color: Config.getColor("border.subtle")
                border.width: 1

                Behavior on height {
                    NumberAnimation {
                        id: sourceDropdownAnim
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Column {
                    id: sourceDropdownColumn
                    width: parent.width
                    anchors.top: parent.top
                    anchors.margins: 4
                    spacing: 1

                    Repeater {
                        model: Volume.sourceNodes

                        Rectangle {
                            required property var modelData
                            property bool isActive: Pipewire.defaultAudioSource && modelData.name === Pipewire.defaultAudioSource.name
                            width: sourceDropdownColumn.width
                            height: 30
                            radius: 4
                            color: isActive
                                ? Qt.rgba(Config.getColor("primary.blue").r, Config.getColor("primary.blue").g, Config.getColor("primary.blue").b, 0.15)
                                : sourceItemMouse.containsMouse
                                    ? Config.getColor("background.tertiary")
                                    : "transparent"

                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                Text {
                                    text: parent.parent.isActive ? "\uf058" : "\uf111"
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyIcon
                                    color: parent.parent.isActive
                                        ? Config.getColor("primary.blue")
                                        : Config.getColor("text.muted")
                                }

                                Text {
                                    text: modelData.description || modelData.name || "Unknown"
                                    color: parent.parent.isActive
                                        ? Config.getColor("primary.blue")
                                        : Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.weight: parent.parent.isActive ? Font.Bold : Font.Normal
                                    font.family: Config.fontFamilyMonospace
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            MouseArea {
                                id: sourceItemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    Volume.setDefaultSource(modelData)
                                    root.sourceDropdownOpen = false
                                }
                            }
                        }
                    }
                }
            }

            // ── Sub-panel overlay (slides in from right) ──
            Item {
                id: subPanelContainer
                anchors.fill: parent
                clip: true
                visible: root.activeSubPanel !== "" || subPanelSlideAnim.running

                Rectangle {
                    id: subPanelContent
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width
                    x: root.activeSubPanel !== "" ? 0 : width
                    color: Config.getColor("background.crust")
                    radius: 12

                    Behavior on x {
                        NumberAnimation {
                            id: subPanelSlideAnim
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    // Sub-panel header
                    Rectangle {
                        id: subPanelHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 44
                        color: Config.getColor("background.mantle")
                        radius: 12
                        z: 1

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 12
                            color: parent.color
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 6
                                color: subBackMouse.containsMouse
                                    ? Config.getColor("background.tertiary")
                                    : "transparent"

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "\uf053"
                                    font.pixelSize: Config.fontSizeMedium
                                    font.family: Config.fontFamilyIcon
                                    color: subBackMouse.containsMouse
                                        ? Config.getColor("text.primary")
                                        : Config.getColor("text.muted")

                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    id: subBackMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.activeSubPanel = ""
                                }
                            }

                            Text {
                                text: root.activeSubPanel === "wifi" ? "\uf1eb"
                                    : root.activeSubPanel === "bluetooth" ? "\uf294"
                                    : ""
                                font.pixelSize: Config.fontSizeHeader
                                font.family: Config.fontFamilyIcon
                                color: Config.getColor("primary.blue")
                            }

                            Text {
                                text: root.activeSubPanel === "wifi" ? "WiFi"
                                    : root.activeSubPanel === "bluetooth" ? "Bluetooth"
                                    : ""
                                color: Config.getColor("text.primary")
                                font.pixelSize: Config.fontSizeHeader
                                font.weight: Font.DemiBold
                                font.family: Config.fontFamilyMonospace
                                Layout.fillWidth: true
                            }
                        }
                    }

                    WifiPanel {
                        anchors.top: subPanelHeader.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        visible: root.activeSubPanel === "wifi"
                    }

                    BluetoothPanel {
                        anchors.top: subPanelHeader.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        visible: root.activeSubPanel === "bluetooth"
                    }
                }
            }
        }
    }
}

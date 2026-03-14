import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.common

MouseArea {
    id: root

    readonly property int updateCount: parseInt(updateCountText.text) || 0
    readonly property bool hasUpdates: updateCount > 0
    readonly property bool isLoading: checkupdatesCountProc.running || checkupdatesFullProc.running
    property bool panelOpen: false

    // Parse updates into structured data, sorted by priority (critical > warning > normal)
    property var updatesList: {
        const text = fullUpdatesCollector.text.trim()
        if (!text) return []
        const updates = text.split('\n').map(line => {
            // Format: "package oldversion -> newversion"
            const match = line.match(/^(\S+)\s+(\S+)\s+->\s+(\S+)$/)
            if (match) {
                return {
                    name: match[1],
                    oldVersion: match[2],
                    newVersion: match[3],
                    priority: Config.getPackagePriority(match[1])
                }
            }
            return { name: line, oldVersion: "", newVersion: "", priority: Config.getPackagePriority(line) }
        })
        // Sort by priority (critical=2, warning=1, normal=0), then alphabetically
        return updates.sort((a, b) => {
            if (a.priority !== b.priority) return b.priority - a.priority
            return a.name.localeCompare(b.name)
        })
    }

    property color primaryColor: Config.barTextColor

    implicitWidth: updatesRow.implicitWidth + 8
    implicitHeight: parent ? parent.height : Config.barHeight
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: function(mouse) {
        if (mouse.button === Qt.RightButton) {
            checkupdatesCountProc.running = true
        } else if (mouse.button === Qt.LeftButton) {
            root.panelOpen = !root.panelOpen
        }
    }

    RowLayout {
        id: updatesRow
        anchors.centerIn: parent
        spacing: 2

        // Arrow icon (static) - shown when not loading
        Text {
            visible: !root.isLoading
            text: "⬆"
            color: root.primaryColor
            font.pixelSize: Config.fontSizeBase
            font.weight: Font.Bold
            font.family: Config.fontFamilyMonospace

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }

        // Spinner icon (rotating) - shown when loading
        Text {
            visible: root.isLoading
            text: "⟳"
            color: root.primaryColor
            font.pixelSize: Config.fontSizeBase
            font.weight: Font.Bold
            font.family: Config.fontFamilyMonospace

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: root.isLoading
            }
        }

        // Count
        Text {
            id: updateCountText
            text: root.updateCount > 99 ? "99" : root.updateCount.toString()
            color: root.primaryColor
            font.pixelSize: Config.fontSizeBase
            font.weight: Font.DemiBold
            font.family: Config.fontFamilyMonospace

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }
    }

    Process {
        id: checkupdatesCountProc
        command: ["sh", "-c", "checkupdates | wc -l"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                updateCountText.text = this.text.trim()
                checkupdatesFullProc.running = true
            }
        }
    }

    Process {
        id: checkupdatesFullProc
        command: ["checkupdates"]
        running: false

        stdout: StdioCollector {
            id: fullUpdatesCollector
        }
    }

    Timer {
        interval: 3600000 // 1 hour
        running: true
        repeat: true
        onTriggered: {
            checkupdatesCountProc.running = true
        }
    }

    // Launch ghostty with yay update command
    Process {
        id: updateProc
        command: [
            "hyprctl", "dispatch", "exec",
            "[float; size 800 600; center]",
            "ghostty --class=ghostty-yay-update --title='System Update' -e sh -c 'echo \"System Update\"; echo \"=============\"; echo; yay -Syu; echo; echo \"Press Enter to close...\"; read'"
        ]
        running: false
    }

    Tooltip {
        hoverTarget: root
        text: {
            if (root.isLoading) return "Checking for updates..."
            if (!root.hasUpdates) return "System up to date\nClick to view • Right-click to refresh"
            return root.updateCount + " update" + (root.updateCount > 1 ? "s" : "") + " available\nClick to view • Right-click to refresh"
        }
    }

    Timer {
        id: updatesHideTimer
        interval: 250
        onTriggered: updatesPanel.visible = false
    }

    onPanelOpenChanged: {
        if (panelOpen) {
            updatesHideTimer.stop()
            updatesPanel.visible = true
        } else {
            updatesHideTimer.restart()
        }
    }

    // Updates panel popup
    PanelWindow {
        id: updatesPanel
        visible: false

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
                root.panelOpen = false
            }
        }

        // Panel content
        Rectangle {
            id: panelContent
            anchors.right: parent.right
            width: 360
            height: Math.min(parent.height * 0.85, 450)
            color: Config.getColor("background.crust")
            border.width: 1
            border.color: Config.getColor("border.subtle")
            radius: 12

            // Fly out from top animation
            clip: true
            y: root.panelOpen ? 0 : -500

            Behavior on y {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            // Prevent clicks from closing
            MouseArea {
                anchors.fill: parent
                onClicked: { }
            }

            Column {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    width: parent.width
                    height: 48
                    color: Config.getColor("background.mantle")
                    radius: 12

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
                            text: "⬆"
                            font.pixelSize: Config.fontSizeHeader
                            font.family: Config.fontFamilyMonospace
                            color: Config.getColor("primary.teal")
                        }

                        Text {
                            text: "System Updates"
                            color: Config.getColor("text.primary")
                            font.pixelSize: Config.fontSizeHeader
                            font.weight: Font.DemiBold
                            font.family: Config.fontFamilyMonospace
                            Layout.fillWidth: true
                        }

                        // Count badge
                        Rectangle {
                            visible: root.hasUpdates
                            width: countText.width + 12
                            height: 20
                            radius: 10
                            color: Config.getColor("primary.teal")

                            Text {
                                id: countText
                                anchors.centerIn: parent
                                text: root.updateCount > 99 ? "99+" : root.updateCount.toString()
                                color: Config.getColor("background.crust")
                                font.pixelSize: Config.fontSizeBase
                                font.weight: Font.Bold
                                font.family: Config.fontFamilyMonospace
                            }
                        }

                        // Update button
                        Rectangle {
                            id: updateButton
                            visible: root.hasUpdates && !root.isLoading
                            width: updateButtonText.width + 16
                            height: 24
                            radius: 6
                            color: updateMouseArea.containsMouse
                                ? Config.getColor("primary.green")
                                : Qt.rgba(Config.getColor("primary.green").r, Config.getColor("primary.green").g, Config.getColor("primary.green").b, 0.2)
                            border.color: Config.getColor("primary.green")
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                id: updateButtonText
                                anchors.centerIn: parent
                                text: "Update"
                                color: updateMouseArea.containsMouse ? Config.getColor("background.crust") : Config.getColor("primary.green")
                                font.pixelSize: Config.fontSizeBase
                                font.weight: Font.DemiBold
                                font.family: Config.fontFamilyMonospace

                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            MouseArea {
                                id: updateMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    updateProc.running = true
                                    root.panelOpen = false
                                }
                            }

                            Tooltip {
                                hoverTarget: updateMouseArea
                                text: "Open terminal to update system"
                            }
                        }

                        // Refresh button
                        Rectangle {
                            id: refreshButton
                            width: 28
                            height: 28
                            radius: 6
                            color: refreshMouseArea.containsMouse
                                ? Qt.rgba(Config.getColor("primary.blue").r, Config.getColor("primary.blue").g, Config.getColor("primary.blue").b, 0.2)
                                : "transparent"
                            border.color: refreshMouseArea.containsMouse ? Config.getColor("primary.blue") : Config.getColor("border.subtle")
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 100 } }
                            Behavior on border.color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: "⟳"
                                color: refreshMouseArea.containsMouse ? Config.getColor("primary.blue") : Config.getColor("text.muted")
                                font.pixelSize: Config.fontSizeMedium
                                font.weight: Font.Bold
                                font.family: Config.fontFamilyMonospace

                                Behavior on color { ColorAnimation { duration: 100 } }

                                RotationAnimation on rotation {
                                    from: 0
                                    to: 360
                                    duration: 1000
                                    loops: Animation.Infinite
                                    running: root.isLoading
                                }
                            }

                            MouseArea {
                                id: refreshMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    checkupdatesCountProc.running = true
                                }
                            }

                            Tooltip {
                                hoverTarget: refreshMouseArea
                                text: "Refresh"
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

                // Content area
                Item {
                    width: parent.width
                    height: parent.height - 49

                    // Loading state
                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        visible: root.isLoading

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "⟳"
                            font.pixelSize: Config.fontSizeIconXL
                            font.family: Config.fontFamilyMonospace
                            color: Config.getColor("primary.blue")

                            RotationAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                                running: root.isLoading
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Checking for updates..."
                            color: Config.getColor("text.muted")
                            font.pixelSize: Config.fontSizeLarge
                            font.weight: Font.Medium
                            font.family: Config.fontFamilyMonospace
                        }
                    }

                    // Empty state
                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        visible: !root.isLoading && !root.hasUpdates

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "✓"
                            font.pixelSize: Config.fontSizeIconXL
                            font.family: Config.fontFamilyMonospace
                            color: Config.getColor("primary.green")
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "System up to date!"
                            color: Config.getColor("text.muted")
                            font.pixelSize: Config.fontSizeLarge
                            font.weight: Font.Medium
                            font.family: Config.fontFamilyMonospace
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No packages need updating"
                            color: Config.getColor("text.muted")
                            font.pixelSize: Config.fontSizeBase
                            font.family: Config.fontFamilyMonospace
                            opacity: 0.7
                        }
                    }

                    // Updates list
                    ListView {
                        id: updatesList
                        anchors.fill: parent
                        anchors.margins: 6
                        visible: !root.isLoading && root.hasUpdates
                        clip: true
                        spacing: 0

                        boundsBehavior: Flickable.StopAtBounds

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            contentItem: Rectangle {
                                implicitWidth: 4
                                radius: 2
                                color: parent.pressed
                                    ? Config.getColor("text.muted")
                                    : parent.hovered
                                        ? Config.getColor("border.primary")
                                        : Config.getColor("border.subtle")
                                opacity: parent.active ? 1.0 : 0.0
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }
                            background: Rectangle {
                                implicitWidth: 4
                                color: "transparent"
                            }
                        }

                        model: root.updatesList

                        delegate: Item {
                            id: updateItem
                            required property var modelData
                            required property int index
                            width: updatesList.width - 4
                            height: 20

                            // Priority: 2 = critical, 1 = warning, 0 = normal
                            readonly property int priority: modelData.priority
                            readonly property bool isCritical: priority === 2
                            readonly property bool isWarning: priority === 1
                            readonly property bool isHighlighted: priority > 0

                            // Color based on priority
                            readonly property color highlightColor: isCritical
                                ? Config.getColor("primary.red")
                                : Config.getColor("primary.yellow")

                            // Background highlight for important packages
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: 3
                                color: updateItem.isHighlighted
                                    ? Qt.rgba(updateItem.highlightColor.r, updateItem.highlightColor.g, updateItem.highlightColor.b, 0.15)
                                    : "transparent"
                                border.width: updateItem.isHighlighted ? 1 : 0
                                border.color: Qt.rgba(updateItem.highlightColor.r, updateItem.highlightColor.g, updateItem.highlightColor.b, 0.3)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6
                                spacing: 0

                                // Priority indicator
                                Text {
                                    visible: updateItem.isHighlighted
                                    text: updateItem.isCritical ? "⚠" : "★"
                                    color: updateItem.highlightColor
                                    font.pixelSize: Config.fontSizeSmall - 1
                                    font.family: Config.fontFamilyMonospace
                                    Layout.rightMargin: 4
                                }

                                // Package name
                                Text {
                                    text: updateItem.modelData.name
                                    color: updateItem.isHighlighted ? updateItem.highlightColor : Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeBase
                                    font.family: Config.fontFamilyMonospace
                                    font.weight: updateItem.isHighlighted ? Font.Bold : Font.Normal
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                // Old version
                                Text {
                                    visible: updateItem.modelData.oldVersion !== ""
                                    text: updateItem.modelData.oldVersion
                                    color: Config.getColor("text.secondary")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }

                                // Arrow
                                Text {
                                    visible: updateItem.modelData.newVersion !== ""
                                    text: " → "
                                    color: updateItem.isHighlighted ? updateItem.highlightColor : Config.getColor("primary.teal")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }

                                // New version
                                Text {
                                    visible: updateItem.modelData.newVersion !== ""
                                    text: updateItem.modelData.newVersion
                                    color: updateItem.isHighlighted ? updateItem.highlightColor : Config.getColor("primary.teal")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

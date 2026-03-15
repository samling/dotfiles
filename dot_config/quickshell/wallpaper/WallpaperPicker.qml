import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: root

        property var modelData
        screen: modelData

        visible: GlobalStates.wallpaperPickerOpen

        anchors {
            top: true
            right: true
            left: true
            bottom: true
        }

        margins {
            top: 40
            right: 40
            left: 40
            bottom: 40
        }

        color: "transparent"

        WlrLayershell.namespace: "quickshell:wallpaper-picker"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        readonly property int columns: 5
        readonly property real thumbnailSpacing: 8
        readonly property real panelPadding: 16

        // Wallpaper directory from user config, falling back to ~/Pictures/Wallpapers
        readonly property string wallpaperDir: {
            const dir = Config.userConfig.wallpaper?.directory
            if (dir) return dir
            return Directories.home.replace("file://", "") + "/Pictures/Wallpapers"
        }

        readonly property string configDir:
            Directories.config.replace("file://", "")

        // Each entry: { fullPath: string, thumbPath: string }
        property var imageList: []
        property bool loading: true

        Component.onCompleted: {
            generateThumbsProc.running = true
        }

        // Generate thumbnails and get the listing in one shot
        Process {
            id: generateThumbsProc
            command: [root.configDir + "/swww/generate_thumbnails.sh", root.wallpaperDir]

            stdout: StdioCollector {
                onStreamFinished: {
                    const text = this.text.trim()
                    if (text) {
                        root.imageList = text.split('\n').map(line => {
                            const parts = line.split('\t')
                            return { fullPath: parts[0], thumbPath: parts[1] }
                        })
                    } else {
                        root.imageList = []
                    }
                    root.loading = false
                }
            }
        }

        // Set wallpaper process
        Process {
            id: setWallpaperProc
            property string imagePath: ""
            command: [root.configDir + "/swww/set_wallpaper.sh", imagePath]
        }

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: GlobalStates.wallpaperPickerOpen = false
        }

        function applySelection() {
            if (gridView.currentIndex >= 0 && gridView.currentIndex < root.imageList.length) {
                setWallpaperProc.imagePath = root.imageList[gridView.currentIndex].fullPath
                setWallpaperProc.running = true
                GlobalStates.wallpaperPickerOpen = false
            }
        }

        onVisibleChanged: {
            if (visible) gridView.forceActiveFocus()
        }

        // Panel content
        Rectangle {
            id: panelContent
            anchors.centerIn: parent
            width: Math.min(parent.width, 900)
            height: Math.min(parent.height, 700)
            color: Config.getColor("background.crust")
            border.width: 1
            border.color: Config.getColor("border.subtle")
            radius: 12
            clip: true

            // Prevent clicks from closing
            MouseArea {
                anchors.fill: parent
                onClicked: function(mouse) { mouse.accepted = true }
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
                            text: "🖼"
                            font.pixelSize: Config.fontSizeHeader
                            font.family: Config.fontFamilyMonospace
                            color: Config.getColor("primary.lavender")
                        }

                        Text {
                            text: "Wallpaper Picker"
                            color: Config.getColor("text.primary")
                            font.pixelSize: Config.fontSizeHeader
                            font.weight: Font.DemiBold
                            font.family: Config.fontFamilyMonospace
                            Layout.fillWidth: true
                        }

                        // Image count badge
                        Rectangle {
                            visible: root.imageList.length > 0
                            width: badgeText.width + 12
                            height: 20
                            radius: 10
                            color: Config.getColor("primary.lavender")

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: root.imageList.length.toString()
                                color: Config.getColor("background.crust")
                                font.pixelSize: Config.fontSizeBase
                                font.weight: Font.Bold
                                font.family: Config.fontFamilyMonospace
                            }
                        }

                        // Close button
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 6
                            color: closeMouseArea.containsMouse
                                ? Qt.rgba(Config.getColor("primary.red").r,
                                          Config.getColor("primary.red").g,
                                          Config.getColor("primary.red").b, 0.2)
                                : "transparent"
                            border.color: closeMouseArea.containsMouse
                                ? Config.getColor("primary.red")
                                : Config.getColor("border.subtle")
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 100 } }
                            Behavior on border.color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: closeMouseArea.containsMouse
                                    ? Config.getColor("primary.red")
                                    : Config.getColor("text.muted")
                                font.pixelSize: Config.fontSizeMedium
                                font.weight: Font.Bold
                                font.family: Config.fontFamilyMonospace
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            MouseArea {
                                id: closeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: GlobalStates.wallpaperPickerOpen = false
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
                        visible: root.loading

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
                                running: root.loading
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Loading wallpapers..."
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
                        visible: !root.loading && root.imageList.length === 0

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "🖼"
                            font.pixelSize: Config.fontSizeIconXL
                            font.family: Config.fontFamilyMonospace
                            color: Config.getColor("text.muted")
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No wallpapers found"
                            color: Config.getColor("text.muted")
                            font.pixelSize: Config.fontSizeLarge
                            font.weight: Font.Medium
                            font.family: Config.fontFamilyMonospace
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.wallpaperDir
                            color: Config.getColor("text.tertiary")
                            font.pixelSize: Config.fontSizeBase
                            font.family: Config.fontFamilyMonospace
                        }
                    }

                    // Thumbnail grid
                    GridView {
                        id: gridView
                        anchors.fill: parent
                        anchors.margins: root.panelPadding
                        visible: !root.loading && root.imageList.length > 0
                        clip: true
                        focus: true
                        currentIndex: -1
                        highlightFollowsCurrentItem: false
                        keyNavigationEnabled: false

                        cellWidth: (width) / root.columns
                        cellHeight: cellWidth * 0.65
                        cacheBuffer: 100000

                        boundsBehavior: Flickable.StopAtBounds

                        Keys.onPressed: (event) => {
                            const cols = root.columns
                            const count = root.imageList.length
                            let idx = gridView.currentIndex

                            if (event.key === Qt.Key_Escape) {
                                GlobalStates.wallpaperPickerOpen = false
                                event.accepted = true
                                return
                            }
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                root.applySelection()
                                event.accepted = true
                                return
                            }

                            // Start at 0 if nothing selected yet
                            if (idx < 0) idx = 0
                            else if (event.key === Qt.Key_Right) idx = Math.min(idx + 1, count - 1)
                            else if (event.key === Qt.Key_Left) idx = Math.max(idx - 1, 0)
                            else if (event.key === Qt.Key_Down) idx = Math.min(idx + cols, count - 1)
                            else if (event.key === Qt.Key_Up) idx = Math.max(idx - cols, 0)
                            else return

                            gridView.currentIndex = idx
                            gridView.positionViewAtIndex(idx, GridView.Contain)
                            event.accepted = true
                        }

                        MouseArea {
                            anchors.fill: parent
                            propagateComposedEvents: true
                            acceptedButtons: Qt.NoButton
                            onWheel: (wheel) => {
                                const scrollDistance = wheel.angleDelta.y * 3
                                gridView.contentY = Math.max(0,
                                    Math.min(gridView.contentY - scrollDistance,
                                             gridView.contentHeight - gridView.height))
                                wheel.accepted = true
                            }
                            onPressed: (mouse) => { mouse.accepted = false }
                        }

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

                        model: root.imageList

                        delegate: Item {
                            id: thumbDelegate
                            required property var modelData
                            required property int index

                            width: gridView.cellWidth
                            height: gridView.cellHeight

                            readonly property bool isSelected: gridView.currentIndex === index

                            Rectangle {
                                id: thumbContainer
                                anchors.fill: parent
                                anchors.margins: root.thumbnailSpacing / 2
                                radius: 8
                                color: Config.getColor("background.mantle")
                                border.width: (thumbMouseArea.containsMouse || thumbDelegate.isSelected) ? 2 : 1
                                border.color: (thumbMouseArea.containsMouse || thumbDelegate.isSelected)
                                    ? Config.getColor("primary.lavender")
                                    : Config.getColor("border.subtle")
                                clip: true

                                Behavior on border.color { ColorAnimation { duration: 100 } }
                                Behavior on border.width { NumberAnimation { duration: 100 } }

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    source: "file://" + thumbDelegate.modelData.thumbPath
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true

                                    // Loading placeholder
                                    Rectangle {
                                        anchors.fill: parent
                                        color: Config.getColor("background.surface")
                                        visible: parent.status === Image.Loading
                                        radius: 7

                                        Text {
                                            anchors.centerIn: parent
                                            text: "⟳"
                                            color: Config.getColor("text.muted")
                                            font.pixelSize: Config.fontSizeIconSmall
                                            font.family: Config.fontFamilyMonospace

                                            RotationAnimation on rotation {
                                                from: 0
                                                to: 360
                                                duration: 1000
                                                loops: Animation.Infinite
                                                running: true
                                            }
                                        }
                                    }
                                }

                                // Hover overlay with filename
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 1
                                    height: 24
                                    color: "#CC000000"
                                    visible: thumbMouseArea.containsMouse || thumbDelegate.isSelected

                                    Text {
                                        anchors.fill: parent
                                        anchors.leftMargin: 6
                                        anchors.rightMargin: 6
                                        verticalAlignment: Text.AlignVCenter
                                        text: thumbDelegate.modelData.fullPath.split('/').pop()
                                        color: "#ffffff"
                                        font.pixelSize: Config.fontSizeSmall
                                        font.family: Config.fontFamilyMonospace
                                        elide: Text.ElideMiddle
                                    }
                                }

                                MouseArea {
                                    id: thumbMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        gridView.currentIndex = thumbDelegate.index
                                        root.applySelection()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

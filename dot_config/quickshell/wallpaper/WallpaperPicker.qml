import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.common

Scope {
    id: pickerScope

    property bool keepAlive: false

    Timer {
        id: pickerUnloadDelay
        interval: 3000
        onTriggered: pickerScope.keepAlive = false
    }

    Connections {
        target: GlobalStates
        function onWallpaperPickerOpenChanged() {
            if (!GlobalStates.wallpaperPickerOpen) {
                pickerScope.keepAlive = true
                pickerUnloadDelay.start()
            }
        }
    }

    Variants {
        model: Quickshell.screens

        LazyLoader {
            id: pickerLoader
            required property ShellScreen modelData
            active: GlobalStates.wallpaperPickerOpen || pickerScope.keepAlive
        component: PanelWindow {
        id: root

        screen: pickerLoader.modelData

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

        // Each entry: { fullPath: string, thumbPath: string, mtime: number }
        property var imageList: []
        property bool loading: true

        // Search and sort state
        property string searchQuery: ""
        property string sortMode: "name" // "name" or "date"

        // Filtered and sorted view of imageList
        readonly property var displayList: {
            let list = root.imageList.slice()
            const query = root.searchQuery.toLowerCase()
            if (query) {
                list = list.filter(item => {
                    const name = item.fullPath.split('/').pop().toLowerCase()
                    return name.includes(query)
                })
            }
            if (root.sortMode === "date") {
                list.sort((a, b) => b.mtime - a.mtime)
            } else {
                list.sort((a, b) => {
                    const nameA = a.fullPath.split('/').pop().toLowerCase()
                    const nameB = b.fullPath.split('/').pop().toLowerCase()
                    return nameA.localeCompare(nameB)
                })
            }
            return list
        }

        // Wait for user config to load before scanning wallpapers
        onWallpaperDirChanged: {
            if (Config.userConfigInitialized) {
                generateThumbsProc.running = true
            }
        }

        Connections {
            target: Config
            function onUserConfigInitializedChanged() {
                if (Config.userConfigInitialized) {
                    generateThumbsProc.running = true
                }
            }
        }

        // Generate thumbnails and get the listing in one shot
        Process {
            id: generateThumbsProc
            command: [root.configDir + "/awww/generate_thumbnails.sh", root.wallpaperDir]

            stdout: StdioCollector {
                onStreamFinished: {
                    const text = this.text.trim()
                    if (text) {
                        root.imageList = text.split('\n').map(line => {
                            const parts = line.split('\t')
                            return { fullPath: parts[0], thumbPath: parts[1], mtime: parseInt(parts[2]) || 0 }
                        })
                    } else {
                        root.imageList = []
                    }
                    root.loading = false
                }
            }
        }

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: GlobalStates.wallpaperPickerOpen = false
        }

        function applySelection() {
            if (gridView.currentIndex >= 0 && gridView.currentIndex < root.displayList.length) {
                const imagePath = root.displayList[gridView.currentIndex].fullPath
                const proc = Qt.createQmlObject(`
                    import Quickshell.Io
                    Process {
                        onExited: destroy()
                    }
                `, pickerScope)
                proc.command = [root.configDir + "/awww/set_wallpaper.sh", imagePath]
                proc.running = true
                GlobalStates.wallpaperPickerOpen = false
            }
        }

        onVisibleChanged: {
            if (visible) {
                searchInput.text = ""
                gridView.forceActiveFocus()
            }
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
                            visible: root.displayList.length > 0
                            width: badgeText.width + 12
                            height: 20
                            radius: 10
                            color: Config.getColor("primary.lavender")

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: root.searchQuery
                                    ? root.displayList.length + "/" + root.imageList.length
                                    : root.imageList.length.toString()
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

                // Search and sort toolbar
                Rectangle {
                    width: parent.width
                    height: 44
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.topMargin: 8
                        anchors.bottomMargin: 4
                        spacing: 8

                        // Search field
                        Rectangle {
                            Layout.fillWidth: true
                            height: 32
                            radius: 6
                            color: Config.getColor("background.mantle")
                            border.width: 1
                            border.color: searchInput.activeFocus
                                ? Config.getColor("primary.lavender")
                                : Config.getColor("border.subtle")

                            Behavior on border.color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                Text {
                                    text: "/"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeBase
                                    font.family: Config.fontFamilyMonospace
                                }

                                TextInput {
                                    id: searchInput
                                    Layout.fillWidth: true
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeBase
                                    font.family: Config.fontFamilyMonospace
                                    clip: true
                                    onTextChanged: root.searchQuery = text

                                    Text {
                                        anchors.fill: parent
                                        text: "Search wallpapers..."
                                        color: Config.getColor("text.tertiary")
                                        font.pixelSize: Config.fontSizeBase
                                        font.family: Config.fontFamilyMonospace
                                        visible: !searchInput.text && !searchInput.activeFocus
                                    }

                                    Keys.onEscapePressed: {
                                        if (searchInput.text) {
                                            searchInput.text = ""
                                        } else {
                                            searchInput.focus = false
                                            gridView.forceActiveFocus()
                                        }
                                    }
                                    Keys.onReturnPressed: {
                                        searchInput.focus = false
                                        gridView.forceActiveFocus()
                                    }
                                    Keys.onDownPressed: {
                                        gridView.forceActiveFocus()
                                    }
                                }

                                // Clear button
                                Text {
                                    text: "✕"
                                    color: Config.getColor("text.muted")
                                    font.pixelSize: Config.fontSizeSmall
                                    font.family: Config.fontFamilyMonospace
                                    visible: searchInput.text !== ""

                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -4
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: searchInput.text = ""
                                    }
                                }
                            }
                        }

                        // Sort toggle
                        Rectangle {
                            width: sortRow.width + 16
                            height: 32
                            radius: 6
                            color: sortMouseArea.containsMouse
                                ? Config.getColor("background.surface")
                                : Config.getColor("background.mantle")
                            border.width: 1
                            border.color: Config.getColor("border.subtle")

                            Behavior on color { ColorAnimation { duration: 100 } }

                            Row {
                                id: sortRow
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: root.sortMode === "name" ? "A-Z" : "⏱"
                                    color: Config.getColor("primary.lavender")
                                    font.pixelSize: Config.fontSizeBase
                                    font.family: Config.fontFamilyMonospace
                                }

                                Text {
                                    text: root.sortMode === "name" ? "Name" : "Date"
                                    color: Config.getColor("text.primary")
                                    font.pixelSize: Config.fontSizeBase
                                    font.family: Config.fontFamilyMonospace
                                }
                            }

                            MouseArea {
                                id: sortMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.sortMode = root.sortMode === "name" ? "date" : "name"
                            }
                        }
                    }
                }

                // Content area
                Item {
                    width: parent.width
                    height: parent.height - 93

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
                        visible: !root.loading && root.displayList.length == 0

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "🖼"
                            font.pixelSize: Config.fontSizeIconXL
                            font.family: Config.fontFamilyMonospace
                            color: Config.getColor("text.muted")
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.searchQuery ? "No matching wallpapers" : "No wallpapers found"
                            color: Config.getColor("text.muted")
                            font.pixelSize: Config.fontSizeLarge
                            font.weight: Font.Medium
                            font.family: Config.fontFamilyMonospace
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.searchQuery ? "Try a different search" : root.wallpaperDir
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
                        visible: !root.loading && root.displayList.length > 0
                        clip: true
                        focus: true
                        currentIndex: -1
                        highlightFollowsCurrentItem: false
                        keyNavigationEnabled: false

                        cellWidth: (width) / root.columns
                        cellHeight: cellWidth * 0.65
                        cacheBuffer: 400

                        boundsBehavior: Flickable.StopAtBounds

                        Keys.onPressed: (event) => {
                            const cols = root.columns
                            const count = root.displayList.length
                            let idx = gridView.currentIndex

                            if (event.key === Qt.Key_Escape) {
                                GlobalStates.wallpaperPickerOpen = false
                                event.accepted = true
                                return
                            }
                            if (event.text === "/") {
                                searchInput.forceActiveFocus()
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

                        model: root.displayList

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
                                border.width: thumbDelegate.isSelected ? 2 : 1
                                border.color: thumbDelegate.isSelected
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
                                    visible: thumbDelegate.isSelected

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
                                    onContainsMouseChanged: {
                                        if (containsMouse) gridView.currentIndex = thumbDelegate.index
                                    }
                                    onClicked: root.applySelection()
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
}

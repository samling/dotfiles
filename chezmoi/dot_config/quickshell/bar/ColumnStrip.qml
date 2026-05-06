pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

// Mini-strip showing the columns of niri's focused workspace, with the
// focused column highlighted. Hidden under hyprland (flat workspace
// model has no column axis).
Item {
    id: root

    property color activeColor: Config.barTextColor
    property color inactiveColor: Qt.darker(Config.barTextColor, 1.6)
    property int tileWidth: 10
    property int tileHeight: 6
    property int tileRadius: 2

    readonly property var cols: Compositor.columns

    visible: Compositor.isNiri && cols.length > 0
    implicitWidth: visible ? row.implicitWidth + 8 : 0
    implicitHeight: parent ? parent.height : Config.barHeight

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 3

        Repeater {
            model: root.cols

            Rectangle {
                required property var modelData
                readonly property bool isFocused: modelData.isFocused
                readonly property int windowCount: modelData.windowIds.length

                Layout.alignment: Qt.AlignVCenter
                width: root.tileWidth
                // Stack of mini-bars when a column has multiple tiles, so a
                // column with 3 stacked windows reads as 3 stripes — extra
                // tiles fall out of the niri "tile" axis.
                height: root.tileHeight * Math.min(windowCount, 3)
                          + Math.max(0, Math.min(windowCount, 3) - 1) * 1
                radius: root.tileRadius
                color: isFocused ? root.activeColor : root.inactiveColor
                opacity: isFocused ? 1.0 : 0.5

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 150 } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (parent.modelData.windowIds.length > 0)
                            Compositor.focusWindow(parent.modelData.windowIds[0])
                    }
                }
            }
        }
    }
}

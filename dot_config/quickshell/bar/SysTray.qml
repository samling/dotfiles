pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.common

Item {
    id: root
    implicitWidth: container.width
    implicitHeight: container.height
    property bool vertical: false
    property bool invertSide: false

    property int containerHeight: Config.barHeight - 16
    property int borderRadius: 4
    property int borderWidth: 1
    property color primaryColor: Config.getColor("border.subtle")

    // Main container with border
    Rectangle {
        id: container
        anchors.centerIn: parent
        width: gridLayout.implicitWidth + 16
        height: root.containerHeight
        radius: root.borderRadius
        color: "transparent"
        border.color: root.primaryColor
        border.width: root.borderWidth

        GridLayout {
            id: gridLayout
            columns: root.vertical ? 1 : -1
            anchors.centerIn: parent
            rowSpacing: 4
            columnSpacing: 6

            // System tray items
            Repeater {
                model: SystemTray.items

                delegate: SysTrayItem {
                    required property SystemTrayItem modelData
                    item: modelData
                    vertical: root.vertical
                    invertSide: root.invertSide
                    Layout.fillHeight: !root.vertical
                    Layout.fillWidth: root.vertical
                }
            }
        }
    }
}

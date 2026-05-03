pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.common

Item {
    id: root
    implicitWidth: gridLayout.implicitWidth + 8
    implicitHeight: parent ? parent.height : Config.barHeight
    property bool vertical: false
    property bool invertSide: false

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

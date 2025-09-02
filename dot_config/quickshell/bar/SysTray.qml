pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.common

Item {
    id: root
    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    property bool vertical: false
    property bool invertSide: false

    Rectangle {
        id: background
        implicitWidth: gridLayout.implicitWidth + 16
        implicitHeight: gridLayout.implicitHeight + 8
        anchors.centerIn: parent
        color: Config.getColor("background.tertiary")
        radius: height / 2
        
        GridLayout {
            id: gridLayout
            columns: root.vertical ? 1 : -1
            anchors.centerIn: parent
            rowSpacing: 6
            columnSpacing: 4

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

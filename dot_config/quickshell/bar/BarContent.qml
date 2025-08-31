import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

Item {
    id: root
    property var screen: root.QsWindow.window?.screen

    Rectangle { // background
        id: barBackground
        anchors {
            fill: parent
            margins: 1
        }
        color: "#161217"
        radius: 1
    }

    // Left section for workspaces
    RowLayout {
        id: leftSection
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            leftMargin: 8
        }
        spacing: 4

        BarGroup {
            id: leftGroup
            Layout.fillHeight: false

            Workspaces {
                id: workspacesWidget
                Layout.fillHeight: true
            }
        }
    }
}
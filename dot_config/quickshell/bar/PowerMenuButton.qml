import QtQuick
import QtQuick.Layouts
import qs.common

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property color accentColor: Config.getColor("primary.lavender")

    signal activated()

    width: 140
    height: 56
    radius: 8
    color: mouseArea.containsMouse
        ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2)
        : Config.getColor("background.tertiary")
    border.color: mouseArea.containsMouse
        ? root.accentColor
        : Config.getColor("border.subtle")
    border.width: 1

    Behavior on color {
        ColorAnimation { duration: 100 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 100 }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.icon
            font.pixelSize: 18
            font.family: "FiraCode Nerd Font Propo"
            color: mouseArea.containsMouse ? root.accentColor : Config.getColor("text.secondary")

            Behavior on color {
                ColorAnimation { duration: 100 }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            font.pixelSize: 11
            font.weight: Font.Medium
            color: mouseArea.containsMouse ? root.accentColor : Config.getColor("text.secondary")

            Behavior on color {
                ColorAnimation { duration: 100 }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.activated()
    }
}

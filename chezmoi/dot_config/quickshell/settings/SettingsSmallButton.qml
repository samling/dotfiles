import QtQuick
import qs.common

Rectangle {
    id: root

    property string text: ""
    signal clicked()

    implicitWidth: label.implicitWidth + 16
    implicitHeight: 28
    radius: 7
    color: enabled && mouse.containsMouse ? Config.getColor("background.tertiary") : Config.getColor("background.mantle")
    border.width: 1
    border.color: Config.getColor("border.subtle")
    opacity: enabled ? 1 : 0.45

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: Config.getColor("text.primary")
        font.pixelSize: Config.fontSizeSmall
        font.family: Config.fontFamilyMonospace
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        onClicked: root.clicked()
    }
}

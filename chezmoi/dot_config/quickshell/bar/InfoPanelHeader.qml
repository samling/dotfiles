import QtQuick
import QtQuick.Layouts
import qs.common

Rectangle {
    id: root

    signal closeRequested()

    color: Config.getColor("background.mantle")
    radius: 11

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
            text: "\uf0e4"
            font.pixelSize: Config.fontSizeHeader
            font.family: Config.fontFamilyIcon
            color: Config.getColor("text.primary")
        }

        Text {
            text: "System"
            color: Config.getColor("text.primary")
            font.pixelSize: Config.fontSizeHeader
            font.weight: Font.DemiBold
            font.family: Config.fontFamilyMonospace
            Layout.fillWidth: true
        }

        Rectangle {
            width: 28
            height: 28
            radius: 6
            color: closeMouse.containsMouse
                ? Qt.rgba(Config.getColor("state.error").r, Config.getColor("state.error").g, Config.getColor("state.error").b, 0.2)
                : "transparent"
            border.color: closeMouse.containsMouse ? Config.getColor("state.error") : Config.getColor("border.subtle")
            border.width: 1

            Behavior on color { ColorAnimation { duration: 100 } }
            Behavior on border.color { ColorAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: closeMouse.containsMouse ? Config.getColor("state.error") : Config.getColor("text.muted")
                font.pixelSize: Config.fontSizeMedium
                font.weight: Font.Bold
                font.family: Config.fontFamilyMonospace

                Behavior on color { ColorAnimation { duration: 100 } }
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.closeRequested()
            }
        }
    }
}

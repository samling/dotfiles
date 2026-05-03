import QtQuick
import QtQuick.Layouts
import qs.common

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property string status: ""
    property bool active: false
    property int iconSize: Config.fontSizeMedium
    property color accentColor: Config.getColor("primary.mauve")

    signal clicked()
    signal expandClicked()

    height: 56
    radius: 8
    color: {
        const fg = Config.getColor("text.primary")
        if (root.active)
            return Qt.rgba(fg.r, fg.g, fg.b, toggleMouse.containsMouse ? 0.28 : 0.18)
        if (toggleMouse.containsMouse)
            return Qt.rgba(fg.r, fg.g, fg.b, 0.10)
        return Config.getColor("background.tertiary")
    }
    border.width: root.active ? 1 : 0
    border.color: root.accentColor

    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 6
        spacing: 8

        // Icon
        Text {
            text: root.icon
            font.pixelSize: root.iconSize
            font.family: Config.fontFamilyIcon
            color: root.active || toggleMouse.containsMouse
                ? Config.getColor("text.primary")
                : Config.getColor("text.muted")

            Behavior on color { ColorAnimation { duration: 100 } }
        }

        // Label + status
        Column {
            Layout.fillWidth: true
            spacing: 1

            Text {
                text: root.label
                font.pixelSize: Config.fontSizeSmall
                font.weight: root.active ? Font.Bold : Font.Medium
                font.family: Config.fontFamilyMonospace
                color: root.active || toggleMouse.containsMouse
                    ? Config.getColor("text.primary")
                    : Config.getColor("text.muted")
                elide: Text.ElideRight
                width: parent.width

                Behavior on color { ColorAnimation { duration: 100 } }
            }

            Text {
                text: root.status
                font.pixelSize: Config.fontSizeSmall - 1
                font.family: Config.fontFamilyMonospace
                color: Config.getColor("text.muted")
                elide: Text.ElideRight
                width: parent.width
                visible: text !== ""
            }
        }

    }

    MouseArea {
        id: toggleMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (event) => {
            if (event.button === Qt.RightButton)
                root.clicked()
            else
                root.expandClicked()
        }
    }
}

import QtQuick
import QtQuick.Layouts
import qs.common

Item {
    id: root
    property color accentColor: "transparent"
    readonly property color textColor: Config.contrastText(accentColor)
    default property alias items: gridLayout.children

    implicitWidth: gridLayout.implicitWidth + Config.pillHorizontalPadding * 2
    implicitHeight: parent ? parent.height : Config.barHeight

    Rectangle {
        id: background
        anchors {
            fill: parent
            topMargin: Config.pillVerticalMargin
            bottomMargin: Config.pillVerticalMargin
        }
        color: root.accentColor
        radius: Config.pillRadius
        border.width: 2
        border.color: Qt.darker(root.accentColor, 1.3)
    }

    GridLayout {
        id: gridLayout
        columns: -1

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            leftMargin: Config.pillHorizontalPadding
            rightMargin: Config.pillHorizontalPadding
        }
        columnSpacing: Config.groupColumnSpacing
        rowSpacing: Config.groupRowSpacing
    }
}

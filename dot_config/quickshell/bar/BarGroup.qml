import QtQuick
import QtQuick.Layouts
import qs.common

Item {
    id: root
    property real padding: 5
    default property alias items: gridLayout.children

    implicitWidth: gridLayout.implicitWidth + Config.groupImplicitWidthPadding
    implicitHeight: gridLayout.implicitHeight

    Rectangle {
        id: background
        anchors {
            fill: parent
            topMargin: 0
            bottomMargin: 0
            leftMargin: Config.groupBackgroundMarginLeft
            rightMargin: Config.groupBackgroundMarginRight
        }
        color: "transparent"
        border.color: Config.groupBorderColor
        border.width: Config.groupBorderWidth
        radius: Config.groupRadius
    }

    GridLayout {
        id: gridLayout
        columns: -1

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }
        columnSpacing: Config.groupColumnSpacing
        rowSpacing: Config.groupRowSpacing
    }
}
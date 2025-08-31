import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property real padding: 5
    default property alias items: gridLayout.children

    Rectangle {
        id: background
        anchors {
            fill: parent
            topMargin: 0
            bottomMargin: 0
            leftMargin: 4
            rightMargin: 4
        }
    }

    GridLayout {
        id: gridLayout
        columns: -1

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: undefined
            left: parent.left
            right: parent.right
            bottom: undefined
            top: undefined
        }
        columnSpacing: 4
        rowSpacing: 12
    }
}
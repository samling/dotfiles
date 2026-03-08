import QtQuick
import QtQuick.Layouts
import qs.common

// Reusable base component for system resource indicators (CPU, Memory, Disk)
MouseArea {
    id: root

    // Required properties
    property real percentage: 0  // 0.0 to 1.0
    property string label: ""    // Short label like "CPU", "MEM", "DSK"
    property color primaryColor: Config.getColor("primary.teal")
    property string tooltipText: ""

    implicitWidth: indicatorRow.implicitWidth + 8
    implicitHeight: parent ? parent.height : Config.barHeight
    hoverEnabled: true

    RowLayout {
        id: indicatorRow
        anchors.centerIn: parent
        spacing: 3

        // Label
        Text {
            text: root.label
            color: Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.7)
            font.pixelSize: 11
            font.weight: Font.Medium
            font.family: "monospace"
            visible: root.label.length > 0

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }

        // Percentage value
        Text {
            text: Math.round(root.percentage * 100) + "%"
            color: root.primaryColor
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.family: "monospace"

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }
    }

    Tooltip {
        hoverTarget: root
        text: root.tooltipText
    }
}

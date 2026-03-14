import QtQuick
import QtQuick.Layouts
import qs.common

// Reusable base component for system resource indicators (CPU, Memory, Disk)
MouseArea {
    id: root

    // Required properties
    property real percentage: 0  // 0.0 to 1.0
    property string label: ""    // Short label like "CPU", "MEM", "DSK"
    property color primaryColor: Config.barTextColor
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
            color: root.primaryColor
            font.pixelSize: Config.fontSizeBase
            font.weight: Font.Medium
            font.family: Config.fontFamilyMonospace
            visible: root.label.length > 0

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }

        // Percentage value
        Text {
            text: Math.round(root.percentage * 100) + "%"
            color: root.primaryColor
            font.pixelSize: Config.fontSizeBase
            font.weight: Font.DemiBold
            font.family: Config.fontFamilyMonospace

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

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

    // Styling properties
    property int indicatorWidth: 48
    property int indicatorHeight: Config.barHeight - 16
    property int borderRadius: 4
    property int borderWidth: 1

    implicitWidth: indicatorWidth
    implicitHeight: indicatorHeight
    hoverEnabled: true

    // Main container with border
    Rectangle {
        id: container
        anchors.centerIn: parent
        width: root.indicatorWidth
        height: root.indicatorHeight
        radius: root.borderRadius
        color: "transparent"
        border.color: root.primaryColor
        border.width: root.borderWidth

        Behavior on border.color {
            ColorAnimation { duration: Config.colorAnimationDuration }
        }

        // Fill bar (background layer)
        Rectangle {
            id: fillBar
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                margins: root.borderWidth + 1
            }
            width: (parent.width - (root.borderWidth + 1) * 2) * Math.min(1, Math.max(0, root.percentage))
            radius: Math.max(0, root.borderRadius - 2)
            color: Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.35)

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }

        // Content layout: label and percentage
        ColumnLayout {
            anchors.centerIn: parent
            spacing: -2

            // Label (small, at top)
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.label
                color: Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.7)
                font.pixelSize: 8
                font.weight: Font.Medium
                font.family: "monospace"
                visible: root.label.length > 0

                Behavior on color {
                    ColorAnimation { duration: Config.colorAnimationDuration }
                }
            }

            // Percentage value
            Text {
                Layout.alignment: Qt.AlignHCenter
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
    }

    Tooltip {
        hoverTarget: root
        text: root.tooltipText
    }
}

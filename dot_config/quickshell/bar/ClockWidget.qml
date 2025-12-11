import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common

MouseArea {
    id: root

    property string timeText: "00:00"
    property string dateText: "Thu, 11 Dec 2025"

    property int containerWidth: 200
    property int containerHeight: Config.barHeight - 16
    property int borderRadius: 4
    property int borderWidth: 1

    property color primaryColor: Config.getColor("primary.lavender")
    property color secondaryColor: Config.getColor("text.secondary")

    implicitWidth: containerWidth
    implicitHeight: containerHeight
    hoverEnabled: true

    // Main container with border
    Rectangle {
        id: container
        anchors.centerIn: parent
        width: root.containerWidth
        height: root.containerHeight
        radius: root.borderRadius
        color: "transparent"
        border.color: root.primaryColor
        border.width: root.borderWidth

        Behavior on border.color {
            ColorAnimation { duration: Config.colorAnimationDuration }
        }

        // Subtle gradient fill
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: root.borderWidth + 1
            }
            radius: Math.max(0, root.borderRadius - 2)
            color: Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.1)

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }

        // Content layout
        RowLayout {
            anchors.centerIn: parent
            spacing: 10

            // Time display
            Text {
                id: timeDisplay
                text: root.timeText
                color: root.primaryColor
                font.pixelSize: 14
                font.weight: Font.Bold
                font.family: "monospace"

                Behavior on color {
                    ColorAnimation { duration: Config.colorAnimationDuration }
                }
            }

            // Separator
            Rectangle {
                width: 1
                height: 14
                color: Config.getColor("border.subtle")
                opacity: 0.6
            }

            // Date display
            Text {
                id: dateDisplay
                text: root.dateText
                color: root.secondaryColor
                font.pixelSize: 11
                font.weight: Font.Medium

                Behavior on color {
                    ColorAnimation { duration: Config.colorAnimationDuration }
                }
            }
        }
    }

    // Process to get time and date
    Process {
        id: dateProc
        command: ["date", "+%H:%M|%a, %d %b %Y"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split("|")
                if (parts.length >= 2) {
                    root.timeText = parts[0]
                    root.dateText = parts[1]
                }
            }
        }
    }

    // Update timer
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}

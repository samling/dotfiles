import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common

MouseArea {
    id: root

    property string timeText: "00:00"
    property string dateText: "Thu, 11 Dec 2025"

    property color primaryColor: Config.getColor("primary.lavender")
    property color secondaryColor: Config.getColor("text.secondary")

    implicitWidth: clockRow.implicitWidth + 12
    implicitHeight: parent ? parent.height : Config.barHeight
    hoverEnabled: true

    RowLayout {
        id: clockRow
        anchors.centerIn: parent
        spacing: 8

        // Time display
        Text {
            text: root.timeText
            color: root.primaryColor
            font.pixelSize: Config.fontSizeLarge
            font.weight: Font.Bold
            font.family: Config.fontFamilyMonospace

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }

        // Separator
        Rectangle {
            width: 1
            height: 12
            color: Config.getColor("border.subtle")
            opacity: 0.6
        }

        // Date display
        Text {
            text: root.dateText
            color: root.secondaryColor
            font.pixelSize: Config.fontSizeBase
            font.weight: Font.Medium
            font.family: Config.fontFamilyMonospace

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
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

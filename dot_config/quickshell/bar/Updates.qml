import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common

MouseArea {
    id: root

    hoverEnabled: true

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Item {
        id: content

        implicitWidth: rowLayout.implicitWidth
        implicitHeight: rowLayout.implicitHeight

        RowLayout {
            id: rowLayout
            anchors.centerIn: parent

            Text {
                id: updateCount
                color: Config.clockTextColor

                font.pixelSize: 12

                verticalAlignment: Text.AlignVCenter

                Process {
                    id: checkupdatesCountProc

                    command: ["sh", "-c", "checkupdates -n | wc -l"]
                    running: true

                    stdout: StdioCollector {
                        onStreamFinished: updateCount.text = this.text
                    }
                }

                Process {
                    id: checkupdatesFullProc

                    command: ["checkupdates", "-n"]
                    running: true

                    stdout: StdioCollector {
                        id: fullUpdatesCollector
                    }
                }

                Timer {
                    interval: 3600000 // 1 hour
                    running: true
                    repeat: true
                    onTriggered: {
                        checkupdatesCountProc.running = true
                        checkupdatesFullProc.running = true
                    }
                }
            }
        }
    }

    Tooltip {
        hoverTarget: root
        text: fullUpdatesCollector.text
    }
}
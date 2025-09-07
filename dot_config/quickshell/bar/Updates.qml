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
            spacing: 4
            
            property int gaugeSize: Config.barHeight - Config.batteryGaugeOffset
            property color primaryColor: Config.clockTextColor
            
            // Updates icon (to the left)
            Item {
                id: updatesIconContainer
                Layout.preferredWidth: rowLayout.gaugeSize * 0.8
                Layout.preferredHeight: rowLayout.gaugeSize * 0.8
                
                Text {
                    anchors.centerIn: parent
                    color: rowLayout.primaryColor
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    font.family: "DejaVu Sans Mono, Liberation Mono, Consolas, monospace"
                    textFormat: Text.PlainText
                    text: "⬆︎"
                }
            }

            // Updates count text (to the right)
            Text {
                id: updateCount
                Layout.alignment: Qt.AlignVCenter
                color: rowLayout.primaryColor
                font.pixelSize: 12
                font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter

            Process {
                id: checkupdatesCountProc

                command: ["sh", "-c", "checkupdates | wc -l"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        updateCount.text = this.text
                        checkupdatesFullProc.running = true
                    }
                }
            }

            Process {
                id: checkupdatesFullProc

                command: ["checkupdates", "-n"]
                running: false

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
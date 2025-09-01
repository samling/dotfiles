import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common

Item {
    id: root

    property bool showDate: true
    
    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent

          Text {
            id: clock
            color: Config.clockTextColor

            font.pixelSize: Config.clockFontSize
            
            verticalAlignment: Text.AlignVCenter

            Process {
                id: dateProc

                command: ["date", "+%H:%M"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: clock.text = this.text
                }
            }

            // use a timer to rerun the process at an interval
            Timer {
                interval: Config.clockUpdateInterval

                // start the timer immediately
                running: true

                // run the timer again when it ends
                repeat: true

                // when the timer is triggered, set the running property of the
                // process to true, which reruns it if stopped.
                onTriggered: dateProc.running = true
            }
        }
    }
}
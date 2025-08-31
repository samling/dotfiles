import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool showDate: true
    
    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

          Text {
            id: clock
            color: "white"
            
            // Set explicit size like workspace rectangles do
            width: implicitWidth
            height: 20
            verticalAlignment: Text.AlignVCenter

            Process {
                // give the process object an id so we can talk
                // about it from the timer
                id: dateProc

                command: ["date"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: clock.text = this.text
                }
            }

            // use a timer to rerun the process at an interval
            Timer {
                // 1000 milliseconds is 1 second
                interval: 1000

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
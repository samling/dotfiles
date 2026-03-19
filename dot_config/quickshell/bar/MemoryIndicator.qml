import QtQuick
import Quickshell.Io
import qs.common

SystemIndicator {
    id: root

    property real memUsage: 0
    property real memTotal: 0
    property real memUsed: 0
    percentage: memUsage
    label: "MEM"
    primaryColor: Config.barTextColor
    tooltipText: ""

    onClicked: {
        GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen
    }

    // Read /proc/meminfo to calculate memory usage
    Process {
        id: memProc
        command: ["cat", "/proc/meminfo"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split('\n')
                let total = 0, available = 0

                for (let line of lines) {
                    if (line.startsWith('MemTotal:')) {
                        total = parseInt(line.split(/\s+/)[1])
                    } else if (line.startsWith('MemAvailable:')) {
                        available = parseInt(line.split(/\s+/)[1])
                    }
                }

                if (total > 0) {
                    root.memTotal = total
                    root.memUsed = total - available
                    root.memUsage = root.memUsed / total
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            memProc.running = true
        }
    }

    Component.onCompleted: {
        memProc.running = true
    }
}

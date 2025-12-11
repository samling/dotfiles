import QtQuick
import Quickshell.Io
import qs.common

SystemIndicator {
    id: root

    property real memUsage: 0
    property real memTotal: 0
    property real memUsed: 0
    property string topProcesses: ""

    percentage: memUsage
    label: "MEM"
    primaryColor: {
        if (memUsage >= 0.90) return Config.getColor("state.error")
        if (memUsage >= 0.75) return Config.getColor("state.warning")
        return Config.getColor("primary.lavender")
    }
    tooltipText: {
        const usedGB = (memUsed / 1048576).toFixed(1)
        const totalGB = (memTotal / 1048576).toFixed(1)
        let text = "Memory: " + usedGB + " / " + totalGB + " GB (" + Math.round(memUsage * 100) + "%)"
        if (topProcesses.length > 0) {
            text += "\n\n─── Top Processes ───\n" + topProcesses
        }
        return text
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

    // Get top 5 memory-consuming processes (shows RSS in human-readable format)
    Process {
        id: topMemProc
        command: ["sh", "-c", "ps -eo comm,rss --sort=-rss | awk 'NR>1 && NR<=6 {mb=$2/1024; if(mb>=1024) printf \"%-12s %5.1fG\\n\", substr($1,1,12), mb/1024; else printf \"%-12s %5.0fM\\n\", substr($1,1,12), mb}'"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.topProcesses = this.text.trim()
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            memProc.running = true
            topMemProc.running = true
        }
    }

    Component.onCompleted: {
        memProc.running = true
        topMemProc.running = true
    }
}

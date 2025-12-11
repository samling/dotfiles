import QtQuick
import Quickshell.Io
import qs.common

SystemIndicator {
    id: root

    property real cpuUsage: 0
    property var prevIdle: 0
    property var prevTotal: 0
    property string topProcesses: ""

    percentage: cpuUsage
    label: "CPU"
    primaryColor: {
        if (cpuUsage >= 0.90) return Config.getColor("state.error")
        if (cpuUsage >= 0.70) return Config.getColor("state.warning")
        return Config.getColor("primary.sky")
    }
    tooltipText: {
        let text = "CPU Usage: " + Math.round(cpuUsage * 100) + "%"
        if (topProcesses.length > 0) {
            text += "\n\n─── Top Processes ───\n" + topProcesses
        }
        return text
    }

    // Read /proc/stat to calculate CPU usage
    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split('\n')
                for (let line of lines) {
                    if (line.startsWith('cpu ')) {
                        const parts = line.split(/\s+/).slice(1).map(Number)
                        // user, nice, system, idle, iowait, irq, softirq, steal
                        const idle = parts[3] + parts[4]  // idle + iowait
                        const total = parts.reduce((a, b) => a + b, 0)

                        if (root.prevTotal > 0) {
                            const idleDelta = idle - root.prevIdle
                            const totalDelta = total - root.prevTotal
                            if (totalDelta > 0) {
                                root.cpuUsage = 1 - (idleDelta / totalDelta)
                            }
                        }

                        root.prevIdle = idle
                        root.prevTotal = total
                        break
                    }
                }
            }
        }
    }

    // Get top 5 CPU-consuming processes (actual % of total CPU capacity)
    // Divides by nproc to convert per-core % to total system %
    Process {
        id: topCpuProc
        command: ["sh", "-c", "cores=$(nproc); top -b -n 1 -o %CPU | awk -v c=$cores 'NR>7 && $9>0 {pct=$9/c; printf \"%-12s %5.1f%%\\n\", substr($12,1,12), pct}' | head -5"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.topProcesses = this.text.trim()
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            topCpuProc.running = true
        }
    }

    Component.onCompleted: {
        cpuProc.running = true
        topCpuProc.running = true
    }
}

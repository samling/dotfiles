import QtQuick
import Quickshell.Io
import qs.common

// Non-visible GPU stats service. Polls nvidia-smi every 5s and exposes
// properties for the InfoPanel's GPU section. Auto-disables when
// nvidia-smi isn't installed or returns no data.
Item {
    id: root

    property bool gpuAvailable: false
    property string gpuName: ""
    property real gpuUsage: 0           // 0.0 - 1.0
    property real gpuTemp: 0            // °C
    property real vramUsed: 0           // MiB
    property real vramTotal: 0          // MiB
    property real powerDraw: 0          // W
    property real fanSpeed: 0           // %, -1 when N/A

    readonly property real vramUsage: vramTotal > 0 ? vramUsed / vramTotal : 0

    Process {
        id: detectProc
        command: ["sh", "-c", "command -v nvidia-smi >/dev/null 2>&1 && echo yes || echo no"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() === "yes") {
                    nameProc.running = true
                    statsProc.running = true
                }
            }
        }
    }

    Process {
        id: nameProc
        command: ["nvidia-smi", "--query-gpu=name", "--format=csv,noheader"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const name = this.text.trim()
                if (name) root.gpuName = name
            }
        }
    }

    Process {
        id: statsProc
        command: [
            "nvidia-smi",
            "--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw,fan.speed",
            "--format=csv,noheader,nounits"
        ]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const line = this.text.trim().split('\n')[0]
                if (!line) return
                const parts = line.split(',').map(s => s.trim())
                if (parts.length < 5) return

                const util = parseFloat(parts[0])
                const temp = parseFloat(parts[1])
                const memUsed = parseFloat(parts[2])
                const memTotal = parseFloat(parts[3])
                const power = parseFloat(parts[4])
                const fan = parts.length > 5 ? parseFloat(parts[5]) : NaN

                if (!isNaN(util)) root.gpuUsage = util / 100
                if (!isNaN(temp)) root.gpuTemp = temp
                if (!isNaN(memUsed)) root.vramUsed = memUsed
                if (!isNaN(memTotal)) root.vramTotal = memTotal
                if (!isNaN(power)) root.powerDraw = power
                root.fanSpeed = isNaN(fan) ? -1 : fan

                root.gpuAvailable = !isNaN(util) && !isNaN(memTotal) && memTotal > 0
            }
        }
    }

    Timer {
        interval: 5000
        running: root.gpuAvailable
        repeat: true
        onTriggered: statsProc.running = true
    }
}

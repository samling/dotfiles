import QtQuick
import Quickshell.Io
import qs.common

SystemIndicator {
    id: root

    property real cpuUsage: 0
    property var prevIdle: 0
    property var prevTotal: 0
    property string topProcesses: ""
    property string cpuGovernor: ""
    property real cpuTemp: 0
    property string fanState: "standard"

    readonly property var fanModes: [
        { value: "0", label: "Standard", icon: "\uf2c9" },
        { value: "1", label: "Quiet",    icon: "\uf4b8" },
        { value: "2", label: "High",     icon: "\uf72e" },
        { value: "3", label: "Full",     icon: "\uf863" },
    ]

    readonly property var governorModes: [
        { value: "performance", label: "Performance", icon: "\uf0e7" },
        { value: "schedutil",   label: "Balanced",    icon: "\uf24e" },
        { value: "powersave",   label: "Powersave",   icon: "\uf06c" },
    ]

    percentage: cpuUsage
    label: "CPU"
    suffix: root.cpuTemp > 0 ? "(" + root.cpuTemp + "C)" : ""
    primaryColor: Config.barTextColor
    tooltipText: ""

    onClicked: {
        GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen
    }

    // Read /sys/devices/system/cpu to get current CPU governor
    Process {
        id: cpuGov
        command: ["cat", "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.cpuGovernor = this.text.trim()
            }
        }
    }

    Process {
        id: cpuTempProc
        command: ["bash", "-c", "sensors -j | jq -r '.\"k10temp-pci-00c3\".Tctl.temp1_input'"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.cpuTemp = Math.round(parseFloat(this.text.trim()))
            }
        }
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

    // Get current fan state
    Process {
        id: fanStateGetProc
        command: ["sudo", "fan_state", "get"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.fanState = this.text.trim()
            }
        }
    }

    // Set fan state
    Process {
        id: fanStateSetProc
        property string mode: "0"
        command: ["sudo", "fan_state", "set", mode]

        stdout: StdioCollector {
            onStreamFinished: {
                fanStateGetProc.running = true
            }
        }
    }

    // Set CPU governor
    Process {
        id: cpuGovSetProc
        property string governor: "schedutil"
        command: ["sudo", "cpupower", "frequency-set", "-g", governor]

        stdout: StdioCollector {
            onStreamFinished: {
                cpuGov.running = true
            }
        }
    }

    function setFanState(mode) {
        fanStateSetProc.mode = mode
        fanStateSetProc.running = true
    }

    function setCpuGovernor(governor) {
        cpuGovSetProc.governor = governor
        cpuGovSetProc.running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            cpuGov.running = true
            cpuTempProc.running = true
            topCpuProc.running = true
        }
    }

    Component.onCompleted: {
        cpuProc.running = true
        cpuGov.running = true
        cpuTempProc.running = true
        topCpuProc.running = true
        fanStateGetProc.running = true
    }
}

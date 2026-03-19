import QtQuick
import Quickshell.Io
import qs.common

SystemIndicator {
    id: root

    property real cpuUsage: 0
    property var prevIdle: 0
    property var prevTotal: 0
    property string powerProfile: ""
    property real cpuTemp: 0
    property string fanState: "standard"

    readonly property var fanModes: [
        { value: "0", label: "Standard", icon: "\uf2c9" },
        { value: "1", label: "Quiet",    icon: "\uf4b8" },
        { value: "2", label: "High",     icon: "\uf72e" },
        { value: "3", label: "Full",     icon: "\uf863" },
    ]

    readonly property var powerProfileModes: [
        { value: "performance",  label: "Performance", icon: "\uf0e7" },
        { value: "balanced",     label: "Balanced",    icon: "\uf24e" },
        { value: "power-saver",  label: "Power Saver", icon: "\uf06c" },
    ]

    percentage: cpuUsage
    label: "CPU"
    suffix: root.cpuTemp > 0 ? "(" + root.cpuTemp + "C)" : ""
    primaryColor: Config.barTextColor
    tooltipText: ""

    onClicked: {
        GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen
    }

    // Get current power profile
    Process {
        id: powerProfileGetProc
        command: ["powerprofilesctl", "get"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.powerProfile = this.text.trim()
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

    // Set power profile
    Process {
        id: powerProfileSetProc
        property string profile: "balanced"
        command: ["powerprofilesctl", "set", profile]

        stdout: StdioCollector {
            onStreamFinished: {
                powerProfileGetProc.running = true
            }
        }
    }

    function setFanState(mode) {
        fanStateSetProc.mode = mode
        fanStateSetProc.running = true
    }

    function setPowerProfile(profile) {
        powerProfileSetProc.profile = profile
        powerProfileSetProc.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            powerProfileGetProc.running = true
            cpuTempProc.running = true
        }
    }

    Component.onCompleted: {
        cpuProc.running = true
        powerProfileGetProc.running = true
        cpuTempProc.running = true
        fanStateGetProc.running = true
    }
}

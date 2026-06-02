pragma Singleton

import QtQuick
import Quickshell
import qs.common

Singleton {
    id: root

    readonly property int fastPollInterval: Config.userConfig.systemStats?.fastPollInterval || 5000
    readonly property int diskPollInterval: Config.userConfig.systemStats?.diskPollInterval || 30000
    readonly property string diskMountPoint: Config.userConfig.systemStats?.diskMountPoint || "/"

    property real cpuUsage: 0
    property var _prevIdle: 0
    property var _prevTotal: 0
    property real cpuTemp: 0
    property string powerProfile: ""
    property string fanState: "standard"

    property real memUsage: 0
    property real memTotal: 0
    property real memUsed: 0

    property real diskUsage: 0
    property string diskTotal: "0"
    property string diskUsed: "0"
    property string diskAvail: "0"

    property bool gpuAvailable: false
    property string gpuName: ""
    property real gpuUsage: 0
    property real gpuTemp: 0
    property real vramUsed: 0
    property real vramTotal: 0
    property real powerDraw: 0
    property real fanSpeed: 0

    readonly property bool fanControlAvailable: ProgramChecker.fanStateAvailable
    readonly property bool powerProfileAvailable: ["performance", "balanced", "power-saver"].indexOf(powerProfile) !== -1
    readonly property real vramUsage: vramTotal > 0 ? vramUsed / vramTotal : 0

    readonly property var fanModes: fanControlAvailable ? [
        { value: "1", label: "Quiet",    icon: "󱑱" },
        { value: "0", label: "Standard", icon: "󱑲" },
        { value: "2", label: "High",     icon: "󱑳" },
        { value: "3", label: "Full",     icon: "󱑴" },
    ] : []

    readonly property var powerProfileModes: [
        { value: "performance",  label: "Performance", icon: "\uf0e7" },
        { value: "balanced",     label: "Balanced",    icon: "\uf24e" },
        { value: "power-saver",  label: "Power Saver", icon: "\uf06c" },
    ]

    Timer {
        interval: root.fastPollInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.refreshCpu()
            root.refreshMemory()
            root.refreshCpuTemp()
            root.refreshPowerProfile()
        }
    }

    Timer {
        interval: root.diskPollInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshDisk()
    }

    Timer {
        interval: root.fastPollInterval
        running: Config.showGpu && root.gpuAvailable
        repeat: true
        onTriggered: root.refreshGpu()
    }

    onFanControlAvailableChanged: {
        if (fanControlAvailable) refreshFanState()
    }

    Connections {
        target: ProgramChecker

        function onNvidiaSmiAvailableChanged() {
            if (ProgramChecker.nvidiaSmiAvailable && Config.showGpu) {
                root.refreshGpuName()
                root.refreshGpu()
            } else {
                root.gpuAvailable = false
            }
        }

        function onPowerprofilesctlAvailableChanged() {
            root.refreshPowerProfile()
        }
    }

    Component.onCompleted: {
        if (fanControlAvailable) refreshFanState()
        if (ProgramChecker.nvidiaSmiAvailable && Config.showGpu) {
            refreshGpuName()
            refreshGpu()
        }
    }

    function refreshCpu() {
        Proc.run("systemstats-cpu", ["cat", "/proc/stat"], function(stdoutText) {
            const lines = stdoutText.split('\n')
            for (let line of lines) {
                if (!line.startsWith("cpu ")) continue

                const parts = line.split(/\s+/).slice(1).map(Number)
                const idle = parts[3] + parts[4]
                const total = parts.reduce((a, b) => a + b, 0)

                if (root._prevTotal > 0) {
                    const idleDelta = idle - root._prevIdle
                    const totalDelta = total - root._prevTotal
                    if (totalDelta > 0) root.cpuUsage = 1 - (idleDelta / totalDelta)
                }

                root._prevIdle = idle
                root._prevTotal = total
                break
            }
        })
    }

    function refreshCpuTemp() {
        if (!ProgramChecker.sensorsAvailable || !ProgramChecker.jqAvailable) {
            root.cpuTemp = 0
            return
        }

        Proc.run("systemstats-cpu-temp", ["bash", "-c", "sensors -j | jq -r '.\"k10temp-pci-00c3\".Tctl.temp1_input'"], function(stdoutText) {
            const temp = Math.round(parseFloat(stdoutText.trim()))
            if (!isNaN(temp)) root.cpuTemp = temp
        })
    }

    function refreshPowerProfile() {
        if (!ProgramChecker.powerprofilesctlAvailable) {
            root.powerProfile = ""
            return
        }

        Proc.run("systemstats-power-profile", ["powerprofilesctl", "get"], function(stdoutText) {
            root.powerProfile = stdoutText.trim()
        })
    }

    function refreshFanState() {
        if (!fanControlAvailable) return
        Proc.run("systemstats-fan-state", ["sudo", "-n", "fan_state", "get"], function(stdoutText) {
            const state = stdoutText.trim()
            if (state) root.fanState = state
        })
    }

    function setFanState(mode) {
        if (!fanControlAvailable) return
        Proc.run("systemstats-fan-state-set", ["sudo", "-n", "fan_state", "set", mode], function() {
            root.refreshFanState()
        }, 0)
    }

    function setPowerProfile(profile) {
        if (!ProgramChecker.powerprofilesctlAvailable) return
        Proc.run("systemstats-power-profile-set", ["powerprofilesctl", "set", profile], function() {
            root.refreshPowerProfile()
        }, 0)
    }

    function refreshMemory() {
        Proc.run("systemstats-memory", ["cat", "/proc/meminfo"], function(stdoutText) {
            const lines = stdoutText.split('\n')
            let total = 0
            let available = 0

            for (let line of lines) {
                if (line.startsWith("MemTotal:")) total = parseInt(line.split(/\s+/)[1])
                else if (line.startsWith("MemAvailable:")) available = parseInt(line.split(/\s+/)[1])
            }

            if (total > 0) {
                root.memTotal = total
                root.memUsed = total - available
                root.memUsage = root.memUsed / total
            }
        })
    }

    function refreshDisk() {
        Proc.run("systemstats-disk", ["df", "-h", root.diskMountPoint], function(stdoutText) {
            const lines = stdoutText.split('\n')
            if (lines.length < 2) return

            const parts = lines[1].split(/\s+/)
            if (parts.length < 5) return

            root.diskTotal = parts[1]
            root.diskUsed = parts[2]
            root.diskAvail = parts[3]
            root.diskUsage = parseInt(parts[4].replace("%", "")) / 100
        })
    }

    function refreshGpuName() {
        if (!ProgramChecker.nvidiaSmiAvailable || !Config.showGpu) return
        Proc.run("systemstats-gpu-name", ["nvidia-smi", "--query-gpu=name", "--format=csv,noheader"], function(stdoutText) {
            const name = stdoutText.trim()
            if (name) root.gpuName = name
        })
    }

    function refreshGpu() {
        if (!ProgramChecker.nvidiaSmiAvailable || !Config.showGpu) {
            root.gpuAvailable = false
            return
        }

        Proc.run("systemstats-gpu", [
            "nvidia-smi",
            "--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw,fan.speed",
            "--format=csv,noheader,nounits"
        ], function(stdoutText) {
            const line = stdoutText.trim().split('\n')[0]
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
        })
    }
}

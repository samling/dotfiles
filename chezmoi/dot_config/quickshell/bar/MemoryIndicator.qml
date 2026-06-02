import QtQuick
import qs.common
import qs.services

SystemIndicator {
    id: root

    readonly property real memUsage: SystemStats.memUsage
    readonly property real memTotal: SystemStats.memTotal
    readonly property real memUsed: SystemStats.memUsed

    percentage: memUsage
    icon: "󰘚"
    primaryColor: Config.barTextColor
    tooltipText: {
        let used = (memUsed / 1048576).toFixed(1)
        let total = (memTotal / 1048576).toFixed(1)
        return "Memory: " + Math.round(memUsage * 100) + "%\n" + used + "G / " + total + "G"
    }
}

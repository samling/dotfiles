import QtQuick
import qs.common
import qs.services

SystemIndicator {
    id: root

    readonly property real diskUsage: SystemStats.diskUsage
    readonly property string diskTotal: SystemStats.diskTotal
    readonly property string diskUsed: SystemStats.diskUsed
    readonly property string diskAvail: SystemStats.diskAvail
    readonly property string mountPoint: SystemStats.diskMountPoint

    percentage: diskUsage
    icon: "\uf0a0"
    primaryColor: Config.barTextColor
    tooltipText: "Disk (" + mountPoint + "): " + Math.round(diskUsage * 100) + "%\n" + diskUsed + " / " + diskTotal + " (Avail: " + diskAvail + ")"
}

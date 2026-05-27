import QtQuick
import qs.common
import qs.services

SystemIndicator {
    id: root

    readonly property real cpuUsage: SystemStats.cpuUsage
    readonly property string powerProfile: SystemStats.powerProfile
    readonly property real cpuTemp: SystemStats.cpuTemp
    readonly property string fanState: SystemStats.fanState
    readonly property bool fanControlAvailable: SystemStats.fanControlAvailable
    readonly property bool powerProfileAvailable: SystemStats.powerProfileAvailable
    readonly property var fanModes: SystemStats.fanModes
    readonly property var powerProfileModes: SystemStats.powerProfileModes

    percentage: cpuUsage
    icon: "\uf2db"
    suffix: ""
    primaryColor: Config.barTextColor
    tooltipText: {
        let text = "CPU: " + Math.round(cpuUsage * 100) + "%"
        if (root.cpuTemp > 0) text += "\nTemp: " + root.cpuTemp + "°C"
        if (root.powerProfile) text += "\nProfile: " + root.powerProfile
        return text
    }

    function setFanState(mode) {
        SystemStats.setFanState(mode)
    }

    function setPowerProfile(profile) {
        SystemStats.setPowerProfile(profile)
    }
}

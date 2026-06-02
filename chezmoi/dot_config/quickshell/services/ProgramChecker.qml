pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool nmcliAvailable: false
    property bool brightnessctlAvailable: false
    property bool sensorsAvailable: false
    property bool jqAvailable: false
    property bool nvidiaSmiAvailable: false
    property bool tailscaleAvailable: false
    property bool powerprofilesctlAvailable: false
    property bool fanStateAvailable: false

    readonly property var programs: ({
        nmcliAvailable: "nmcli",
        brightnessctlAvailable: "brightnessctl",
        sensorsAvailable: "sensors",
        jqAvailable: "jq",
        nvidiaSmiAvailable: "nvidia-smi",
        tailscaleAvailable: "tailscale",
        powerprofilesctlAvailable: "powerprofilesctl",
        fanStateAvailable: "fan_state"
    })

    function refresh() {
        Object.keys(programs).forEach(function(propertyName) {
            const binary = programs[propertyName]
            Proc.run("program-check-" + binary,
                ["sh", "-c", "command -v " + binary + " >/dev/null 2>&1"],
                function(_, exitCode) { root[propertyName] = exitCode === 0 })
        })
    }

    Component.onCompleted: refresh()
}

import QtQuick
import Quickshell.Io
import qs.common

SystemIndicator {
    id: root

    property real diskUsage: 0
    property string diskTotal: "0"
    property string diskUsed: "0"
    property string diskAvail: "0"
    property string mountPoint: "/"  // Monitor root by default

    percentage: diskUsage
    label: "DSK"
    primaryColor: {
        if (diskUsage >= 0.90) return Config.getColor("state.error")
        if (diskUsage >= 0.80) return Config.getColor("state.warning")
        return Config.getColor("primary.peach")
    }
    tooltipText: "Disk (" + mountPoint + "): " + diskUsed + " / " + diskTotal + " (" + Math.round(diskUsage * 100) + "% used)\nAvailable: " + diskAvail

    // Use df to get disk usage
    Process {
        id: diskProc
        command: ["df", "-h", root.mountPoint]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split('\n')
                // Skip header, parse second line
                if (lines.length >= 2) {
                    const parts = lines[1].split(/\s+/)
                    // Format: Filesystem, Size, Used, Avail, Use%, Mounted
                    if (parts.length >= 5) {
                        root.diskTotal = parts[1]
                        root.diskUsed = parts[2]
                        root.diskAvail = parts[3]
                        // Parse percentage (remove % sign)
                        const pctStr = parts[4].replace('%', '')
                        root.diskUsage = parseInt(pctStr) / 100
                    }
                }
            }
        }
    }

    Timer {
        interval: 30000  // Check every 30 seconds (disk changes slowly)
        running: true
        repeat: true
        onTriggered: diskProc.running = true
    }

    Component.onCompleted: {
        diskProc.running = true
    }
}

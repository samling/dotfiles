pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool enabled: false
    property bool connected: false
    property string ssid: ""
    property int signalStrength: 0
    property string ipAddress: ""
    property string security: ""
    property var networks: []
    property bool scanning: false
    property bool pauseListUpdates: false

    // Wired connection info
    property bool wiredConnected: false
    property string wiredName: ""
    property string wiredIpAddress: ""

    // Check WiFi radio state
    Process {
        id: radioProc
        command: ["nmcli", "-t", "-f", "WIFI", "radio"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.enabled = this.text.trim() === "enabled"
            }
        }
    }

    // Check current connection status
    Process {
        id: statusProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split('\n')
                let foundWifi = false
                let foundWired = false
                for (let line of lines) {
                    const parts = line.split(':')
                    if (parts[0] === "wifi" && !foundWifi) {
                        root.connected = parts[1] === "connected"
                        root.ssid = root.connected ? parts.slice(2).join(':') : ""
                        foundWifi = true
                    } else if (parts[0] === "ethernet" && !foundWired) {
                        root.wiredConnected = parts[1] === "connected"
                        root.wiredName = root.wiredConnected ? parts.slice(2).join(':') : ""
                        foundWired = true
                    }
                }
                if (!foundWifi) {
                    root.connected = false
                    root.ssid = ""
                }
                if (!foundWired) {
                    root.wiredConnected = false
                    root.wiredName = ""
                }
                if (root.connected && root.ssid) {
                    ipProc.running = true
                }
                if (root.wiredConnected && root.wiredName) {
                    wiredIpProc.running = true
                }
            }
        }
    }

    // Get IP address of active WiFi connection
    Process {
        id: ipProc
        command: ["nmcli", "-t", "-f", "IP4.ADDRESS", "connection", "show", "--active", root.ssid]

        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text.trim()
                if (text) {
                    const match = text.split(':')
                    if (match.length >= 2) {
                        root.ipAddress = match.slice(1).join(':').split('/')[0]
                    }
                }
            }
        }
    }

    // Get IP address of active wired connection
    Process {
        id: wiredIpProc
        command: ["nmcli", "-t", "-f", "IP4.ADDRESS", "connection", "show", "--active", root.wiredName]

        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text.trim()
                if (text) {
                    const match = text.split(':')
                    if (match.length >= 2) {
                        root.wiredIpAddress = match.slice(1).join(':').split('/')[0]
                    }
                }
            }
        }
    }

    // Scan for available networks
    Process {
        id: scanProc
        command: ["nmcli", "device", "wifi", "rescan"]

        onExited: {
            root.scanning = false
            listProc.running = true
        }
    }

    // List available networks
    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE", "device", "wifi", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split('\n')
                const seen = {}
                const nets = []
                for (let line of lines) {
                    // Format: SSID:SIGNAL:SECURITY:IN-USE
                    // SSID can contain colons, so parse from the right
                    const parts = line.split(':')
                    if (parts.length < 4) continue

                    const inUse = parts[parts.length - 1] === "*"
                    const security = parts[parts.length - 2]
                    const signal = parseInt(parts[parts.length - 3])
                    const ssid = parts.slice(0, parts.length - 3).join(':')

                    if (!ssid || ssid === "--") continue
                    // Keep the strongest signal for duplicate SSIDs
                    if (seen[ssid] && seen[ssid] >= signal) continue
                    seen[ssid] = signal

                    // Update current connection signal strength
                    if (inUse) {
                        root.signalStrength = signal
                        root.security = security
                    }

                    nets.push({
                        ssid: ssid,
                        signal: signal,
                        security: security,
                        inUse: inUse
                    })
                }

                // Sort: in-use first, then by signal strength descending
                nets.sort((a, b) => {
                    if (a.inUse !== b.inUse) return b.inUse - a.inUse
                    return b.signal - a.signal
                })

                // Deduplicate
                const unique = []
                const uniqueSeen = {}
                for (let net of nets) {
                    if (!uniqueSeen[net.ssid]) {
                        uniqueSeen[net.ssid] = true
                        unique.push(net)
                    }
                }

                root.networks = unique
            }
        }
    }

    // Toggle WiFi radio
    Process {
        id: toggleProc
        property string action: "on"
        command: ["nmcli", "radio", "wifi", action]

        onExited: {
            checkStatus()
        }
    }

    // Connect to a network
    Process {
        id: connectProc
        property string targetSsid: ""
        property string password: ""
        command: password
            ? ["nmcli", "device", "wifi", "connect", targetSsid, "password", password]
            : ["nmcli", "device", "wifi", "connect", targetSsid]

        onExited: (exitCode) => {
            if (exitCode === 0) {
                console.log("[Wifi] Connected to " + targetSsid)
            } else {
                console.warn("[Wifi] Failed to connect to " + targetSsid)
            }
            checkStatus()
        }
    }

    // Connect to a hidden network
    Process {
        id: hiddenConnectProc
        property string targetSsid: ""
        property string password: ""
        command: password
            ? ["nmcli", "device", "wifi", "connect", targetSsid, "password", password, "hidden", "yes"]
            : ["nmcli", "device", "wifi", "connect", targetSsid, "hidden", "yes"]

        onExited: (exitCode) => {
            if (exitCode === 0) {
                console.log("[Wifi] Connected to hidden network " + targetSsid)
            } else {
                console.warn("[Wifi] Failed to connect to hidden network " + targetSsid)
            }
            checkStatus()
        }
    }

    // Disconnect from current network
    Process {
        id: disconnectProc
        command: ["nmcli", "device", "disconnect", "wlan0"]

        onExited: {
            checkStatus()
        }
    }

    Timer {
        id: statusTimer
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkStatus()
    }

    function checkStatus() {
        if (!radioProc.running) radioProc.running = true
        if (!statusProc.running) statusProc.running = true
        if (!pauseListUpdates && !listProc.running) listProc.running = true
    }

    function toggle() {
        toggleProc.action = root.enabled ? "off" : "on"
        toggleProc.running = true
    }

    function scan() {
        root.scanning = true
        scanProc.running = true
    }

    function connectToNetwork(ssid, password) {
        connectProc.targetSsid = ssid
        connectProc.password = password || ""
        connectProc.running = true
    }

    function connectToHiddenNetwork(ssid, password) {
        hiddenConnectProc.targetSsid = ssid
        hiddenConnectProc.password = password || ""
        hiddenConnectProc.running = true
    }

    function disconnect() {
        disconnectProc.running = true
    }
}

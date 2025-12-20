pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: tailscale
    property bool connected: false
    property string nodeName: ""
    property string tailnetName: ""
    property string tailnetDomain: ""
    property bool userMode: false
    property var connectedPeers: []
    property int lastUpdateTime: 0
    
    // Timer for periodic updates
    Timer {
        id: updateTimer
        interval: 30000 // 30 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkStatus()
    }
    
    Process {
        id: statusProcess
        command: ["tailscale", "status", "--json"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const statusData = JSON.parse(text)
                    const backendState = statusData.BackendState || ""
                    
                    // Consider connected if backend state is "Running"
                    tailscale.connected = backendState === "Running"
                    
                    // Extract node name and tailnet details
                    if (statusData.Self) {
                        tailscale.nodeName = statusData.Self.HostName || ""
                        tailscale.tailnetName = statusData.Self.TailscaleIPs && statusData.Self.TailscaleIPs.length > 0 ? 
                                                statusData.Self.TailscaleIPs[0] : ""
                    }
                    
                    // Extract tailnet domain
                    tailscale.tailnetDomain = statusData.MagicDNSSuffix || ""
                    
                    // Extract all peers (online and offline)
                    let peers = []
                    if (statusData.Peer) {
                        for (let peerKey in statusData.Peer) {
                            const peer = statusData.Peer[peerKey]
                            // Use DNSName and strip the tailnet suffix for cleaner display
                            let dnsName = peer.DNSName || peer.HostName || "Unknown"
                            // Remove trailing dot and tailnet domain if present
                            if (dnsName.endsWith(".")) {
                                dnsName = dnsName.slice(0, -1)
                            }
                            const domainSuffix = "." + (statusData.MagicDNSSuffix || "")
                            if (domainSuffix.length > 1 && dnsName.endsWith(domainSuffix)) {
                                dnsName = dnsName.slice(0, -domainSuffix.length)
                            }

                            const peerInfo = {
                                hostname: dnsName,
                                ip: peer.TailscaleIPs && peer.TailscaleIPs.length > 0 ? peer.TailscaleIPs[0] : "No IP",
                                os: peer.OS || "",
                                online: peer.Online || false,
                                lastSeen: peer.LastSeen || ""
                            }
                            peers.push(peerInfo)
                        }
                    }
                    // Sort: online devices first, then alphabetically
                    peers.sort((a, b) => {
                        if (a.online !== b.online) return b.online - a.online
                        return a.hostname.localeCompare(b.hostname)
                    })
                    tailscale.connectedPeers = peers
                    
                    tailscale.lastUpdateTime = Date.now()
                } catch (e) {
                    console.error("[Tailscale] Failed to parse status:", e)
                    tailscale.connected = false
                    tailscale.nodeName = ""
                    tailscale.tailnetName = ""
                    tailscale.tailnetDomain = ""
                    tailscale.connectedPeers = []
                }
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    console.warn("[Tailscale] Status check error:", text)
                    tailscale.connected = false
                    tailscale.connectedPeers = []
                }
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("[Tailscale] Status command failed with exit code:", exitCode)
                tailscale.connected = false
                tailscale.connectedPeers = []
            }
        }
    }
    
    // Check if user mode is enabled (can run tailscale commands without sudo)
    Process {
        id: userModeProcess
        command: ["tailscale", "debug", "prefs"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                // If we can run debug prefs without error, user mode is likely enabled
                tailscale.userMode = true
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                // If there's stderr output, check if it's a permission error
                if (text.includes("permission") || text.includes("must be root") || text.includes("Operation not permitted")) {
                    tailscale.userMode = false
                } else {
                    // Other errors might not be permission related
                    tailscale.userMode = true
                }
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                tailscale.userMode = true
            } else {
                tailscale.userMode = false
            }
        }
    }
    
    function checkStatus() {
        if (!statusProcess.running) {
            statusProcess.running = true
        }
        // Also check user mode periodically
        if (!userModeProcess.running) {
            userModeProcess.running = true
        }
    }
    
    function toggleConnection() {
        if (connected) {
            disconnectTailscale()
        } else {
            connectTailscale()
        }
    }
    
    function connectTailscale() {
        const connectProcess = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["tailscale", "up"]
                onExited: {
                    if (exitCode === 0) {
                        console.log("[Tailscale] Connected successfully")
                        checkStatus()
                    } else {
                        console.error("[Tailscale] Failed to connect, exit code:", exitCode)
                    }
                    destroy()
                }
            }
        `, this)
        connectProcess.running = true
    }
    
    function disconnectTailscale() {
        const disconnectProcess = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["tailscale", "down"]
                onExited: {
                    if (exitCode === 0) {
                        console.log("[Tailscale] Disconnected successfully")
                        checkStatus()
                    } else {
                        console.error("[Tailscale] Failed to disconnect, exit code:", exitCode)
                    }
                    destroy()
                }
            }
        `, this)
        disconnectProcess.running = true
    }
}

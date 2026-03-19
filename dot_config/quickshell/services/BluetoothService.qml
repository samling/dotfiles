pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property bool available: Bluetooth.defaultAdapter !== null
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property bool discovering: Bluetooth.defaultAdapter?.discovering ?? false
    readonly property string adapterName: Bluetooth.defaultAdapter?.name ?? ""

    // All devices from the adapter
    readonly property var devices: Bluetooth.devices

    // Computed lists
    readonly property var connectedDevices: filterDevices(d => d.connected)
    readonly property var pairedDevices: filterDevices(d => d.paired && !d.connected)
    readonly property int connectedCount: connectedDevices.length

    // Re-filter when devices change
    property int _refreshTick: 0
    Timer {
        id: refreshTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: root._refreshTick++
    }

    function filterDevices(predicate) {
        void(root._refreshTick)
        if (!Bluetooth.devices) return []
        const result = []
        for (let i = 0; i < Bluetooth.devices.values.length; i++) {
            const device = Bluetooth.devices.values[i]
            if (predicate(device)) {
                result.push(device)
            }
        }
        return result
    }

    function toggle() {
        if (!Bluetooth.defaultAdapter) return
        Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
    }

    function startDiscovery() {
        if (!Bluetooth.defaultAdapter) return
        Bluetooth.defaultAdapter.discovering = true
    }

    function stopDiscovery() {
        if (!Bluetooth.defaultAdapter) return
        Bluetooth.defaultAdapter.discovering = false
    }

    function connectDevice(device) {
        device.connect()
    }

    function disconnectDevice(device) {
        device.disconnect()
    }

    function pairDevice(device) {
        device.pair()
    }

    function forgetDevice(device) {
        device.forget()
    }
}

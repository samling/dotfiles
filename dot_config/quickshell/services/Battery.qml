pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool isPluggedIn: chargeState == isCharging || UPowerDeviceState.PendingCharge
    property real percentage: UPower.displayDevice.percentage
}
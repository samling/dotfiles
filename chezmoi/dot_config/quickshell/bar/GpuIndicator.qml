import QtQuick
import qs.services

// Non-visible proxy kept for existing InfoPanel wiring. Metrics now come from
// the shared SystemStats service instead of a bar-local polling component.
Item {
    readonly property bool gpuAvailable: SystemStats.gpuAvailable
    readonly property string gpuName: SystemStats.gpuName
    readonly property real gpuUsage: SystemStats.gpuUsage
    readonly property real gpuTemp: SystemStats.gpuTemp
    readonly property real vramUsed: SystemStats.vramUsed
    readonly property real vramTotal: SystemStats.vramTotal
    readonly property real powerDraw: SystemStats.powerDraw
    readonly property real fanSpeed: SystemStats.fanSpeed
    readonly property real vramUsage: SystemStats.vramUsage
}

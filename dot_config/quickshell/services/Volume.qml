pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
    }

    property bool available: Pipewire.defaultAudioSink?.ready ?? false
    property bool mutedState: Pipewire.defaultAudioSink?.audio?.muted ?? false
    property real percentage: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    property string deviceName: Pipewire.defaultAudioSink?.description ?? Pipewire.defaultAudioSink?.name ?? ""

    // Audio source (input/microphone)
    property bool sourceAvailable: Pipewire.defaultAudioSource?.ready ?? false
    property bool sourceMutedState: Pipewire.defaultAudioSource?.audio?.muted ?? false
    property real sourcePercentage: Pipewire.defaultAudioSource?.audio?.volume ?? 0
    property string sourceName: Pipewire.defaultAudioSource?.description ?? Pipewire.defaultAudioSource?.name ?? ""

    // All hardware audio devices
    property var sinkNodes: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    property var sourceNodes: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)

    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node
    }

    function setDefaultSource(node) {
        Pipewire.preferredDefaultAudioSource = node
    }
}
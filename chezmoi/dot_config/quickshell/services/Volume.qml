pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
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

    // Sync mic mute LED with audio sink mute state.
    // Detect the platform LED once at startup; skipping the sudo call when
    // the LED is absent avoids password prompts that faillock the user.
    property bool muteLedAvailable: false

    Process {
        id: muteLedProcess
    }

    Process {
        id: muteLedDetectProcess
        command: ["sh", "-c", "test -e /sys/class/leds/platform::micmute/brightness && echo yes || echo no"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                muteLedAvailable = this.text.trim() === "yes"
                if (muteLedAvailable && available) syncMuteLed()
            }
        }
    }

    function syncMuteLed() {
        if (!muteLedAvailable) return
        const val = mutedState ? "1" : "0";
        muteLedProcess.exec(["sudo", "-n", "sh", "-c", "echo " + val + " > /sys/class/leds/platform::micmute/brightness"]);
    }

    onMutedStateChanged: syncMuteLed()
    onAvailableChanged: if (available) syncMuteLed()
}
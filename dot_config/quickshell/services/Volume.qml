pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    property bool available: Pipewire.defaultAudioSink?.ready ?? false
    property bool mutedState: Pipewire.defaultAudioSink?.audio?.muted ?? false
    property real percentage: Pipewire.defaultAudioSink?.audio?.volume ?? 0
}
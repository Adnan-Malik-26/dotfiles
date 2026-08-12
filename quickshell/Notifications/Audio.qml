pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// ============================================================================
// Audio
// Single source of truth for the default sink's volume/mute state.
// VolumeSlider and OSD both bind here instead of touching Pipewire directly —
// keeps the OSD reactive to external changes too (hardware keys, pavucontrol).
// ============================================================================

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property bool ready: sink !== null

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    function setVolume(v) {
        if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1, v))
    }

    function toggleMute() {
        if (sink && sink.audio) sink.audio.muted = !sink.audio.muted
    }
}

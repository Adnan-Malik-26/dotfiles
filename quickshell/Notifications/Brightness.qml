pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// Brightness
// No native Quickshell backlight service exists, so this shells out to
// `brightnessctl`. Polls every 2s so external changes (laptop hotkeys) show
// up in the slider/OSD without a full reload — cheap enough for a single
// text-file read, not worth wiring udev for this scope.
// ============================================================================

Singleton {
    id: root

    property real value: 0.5     // 0..1
    property bool ready: false

    function refresh() { getProc.running = true }

    function setBrightness(v) {
        value = Math.max(0.01, Math.min(1, v))
        setProc.command = ["brightnessctl", "set", Math.round(value * 100) + "%"]
        setProc.running = true
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: getProc
        command: ["brightnessctl", "info"]
        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/\((\d+)%\)/)
                if (m) {
                    root.value = parseInt(m[1]) / 100
                    root.ready = true
                }
            }
        }
    }

    Process {
        id: setProc
    }
}

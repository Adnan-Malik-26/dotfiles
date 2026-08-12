pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// CapsLock
// Watches /sys/class/leds/*capslock*/brightness. Path is discovered once at
// startup (varies by keyboard/driver), then polled at 300ms — this is a
// single-byte sysfs read, negligible cost, and there's no portable inotify
// hook for LED sysfs without extra native code.
// ============================================================================

Singleton {
    id: root

    property bool active: false
    property string ledPath: ""

    Component.onCompleted: findProc.running = true

    Process {
        id: findProc
        command: ["sh", "-c", "find /sys/class/leds -iname '*capslock*' -maxdepth 1 | head -n1"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim()
                if (p !== "") {
                    root.ledPath = p + "/brightness"
                    poll.running = true
                }
            }
        }
    }

    Timer {
        id: poll
        interval: 300
        repeat: true
        onTriggered: readProc.running = true
    }

    Process {
        id: readProc
        command: root.ledPath !== "" ? ["cat", root.ledPath] : ["true"]
        stdout: SplitParser {
            onRead: line => { root.active = line.trim() !== "0" }
        }
    }
}

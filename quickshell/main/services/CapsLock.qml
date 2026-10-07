pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// CapsLock
// Watches /sys/class/leds/*capslock*/brightness. The LED path is discovered
// once at startup (it varies by keyboard/driver), then re-read every 300 ms
// IN-PROCESS via FileView — no subprocess per tick. (Polling stays: there's no
// portable change notification for LED sysfs files.)
// ============================================================================

Singleton {
    id: root

    property bool active: false
    property string ledPath: ""

    Component.onCompleted: findProc.running = true

    // runs once
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

    FileView {
        id: led
        path: root.ledPath
        onLoaded: root.active = text().trim() !== "0"
    }

    Timer {
        id: poll
        interval: 300
        repeat: true
        onTriggered: led.reload()
    }
}

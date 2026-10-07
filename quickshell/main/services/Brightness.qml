pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// Brightness
// Reads the backlight straight from sysfs (FileView, in-process) and only
// shells out to `brightnessctl` when you CHANGE it. `brightnessctl -m info` is
// run once at startup so the device is the same one `brightnessctl set` will
// pick. External changes (laptop hotkeys) are picked up by a 2 s re-read.
// ============================================================================

Singleton {
    id: root

    property real value: 0.5     // 0..1
    property bool ready: false

    property string _dir: ""     // /sys/class/<class>/<name>
    property int _max: 0

    function refresh() { if (_dir !== "") cur.reload() }

    function setBrightness(v) {
        value = Math.max(0.01, Math.min(1, v))
        Quickshell.execDetached(["brightnessctl", "set", Math.round(value * 100) + "%"])
    }

    Component.onCompleted: findProc.running = true

    // runs once; machine-readable line is: name,class,current,percent,max
    Process {
        id: findProc
        command: ["brightnessctl", "-m", "info"]
        stdout: SplitParser {
            onRead: line => {
                const f = line.trim().split(",")
                if (f.length >= 5 && parseInt(f[4]) > 0) {
                    root._max = parseInt(f[4])
                    root._dir = "/sys/class/" + f[1] + "/" + f[0]
                }
            }
        }
        onExited: if (root._dir === "") console.warn("Brightness: could not discover a backlight via `brightnessctl -m info`")
    }

    FileView {
        id: cur
        path: root._dir !== "" ? root._dir + "/brightness" : ""
        onLoaded: {
            const c = parseInt(text())
            if (root._max > 0 && !isNaN(c)) {
                root.value = Math.max(0, Math.min(1, c / root._max))
                root.ready = true
            }
        }
    }

    Timer {
        interval: 2000
        running: root._dir !== ""
        repeat: true
        onTriggered: root.refresh()
    }
}

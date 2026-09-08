pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Single polling source for CPU + memory, shared by island + dashboard.
// Do NOT instantiate this per-widget — Process spawns are not free.
// One Timer, one Process each, read by whoever binds to cpuUsage/memUsage.
QtObject {
    id: root

    readonly property real cpuUsage: _cpuUsage   // 0.0 - 1.0
    readonly property real memUsage: _memUsage   // 0.0 - 1.0
    readonly property real memUsedGb: _memUsedGb
    readonly property real memTotalGb: _memTotalGb

    property real _cpuUsage: 0
    property real _memUsage: 0
    property real _memUsedGb: 0
    property real _memTotalGb: 0

    // --- CPU: diff two /proc/stat samples, standard jiffies math ---
    property var _prevIdle: 0
    property var _prevTotal: 0

    property FileView statFile: FileView {
        path: "/proc/stat"
    }

    property FileView memFile: FileView {
        path: "/proc/meminfo"
    }

    property Timer pollTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload()
            memFile.reload()
        }
    }

    Component.onCompleted: {
        statFile.fileChanged.connect(_onStat)
        memFile.fileChanged.connect(_onMem)
    }

    function _onStat() {
        const line = statFile.text().split("\n")[0] // "cpu  u n s i io irq sirq ..."
        const parts = line.trim().split(/\s+/).slice(1).map(Number)
        const idle = parts[3] + (parts[4] || 0)      // idle + iowait
        const total = parts.reduce((a, b) => a + b, 0)

        const diffIdle = idle - _prevIdle
        const diffTotal = total - _prevTotal

        if (_prevTotal !== 0 && diffTotal > 0) {
            _cpuUsage = 1 - (diffIdle / diffTotal)
        }
        _prevIdle = idle
        _prevTotal = total
    }

    function _onMem() {
        const lines = memFile.text().split("\n")
        const kv = {}
        for (const l of lines) {
            const m = l.match(/^(\w+):\s+(\d+)/)
            if (m) kv[m[1]] = parseInt(m[2], 10) // kB
        }
        const total = kv["MemTotal"] || 1
        const avail = kv["MemAvailable"] || 0
        const used = total - avail

        _memUsage = used / total
        _memUsedGb = used / 1024 / 1024
        _memTotalGb = total / 1024 / 1024
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// Frecency
// Launch count weighted by recency (Firefox-style), persisted as
//   { id: { count, last } }  in ~/.local/share/quickshell/menu/frecency.json
// score() is capped so a strong text match still beats a merely popular item.
// ============================================================================

Singleton {
    id: root

    readonly property string dataDir: Quickshell.env("HOME") + "/.local/share/quickshell/menu"
    property var table: ({})

    function score(id) {
        const r = table[id]
        if (!r) return 0
        const h = 3600000, age = Date.now() - r.last
        const w = age < h ? 4 : age < 24 * h ? 2 : age < 7 * 24 * h ? 0.5 : 0.25
        return Math.min(25, 6 * Math.log(1 + r.count * w) / Math.LN2)
    }

    function record(id) {
        const t = JSON.parse(JSON.stringify(table))
        t[id] = { count: (t[id] ? t[id].count : 0) + 1, last: Date.now() }
        table = t
        file.setText(JSON.stringify(t, null, 1))
    }

    Process {
        command: ["mkdir", "-p", root.dataDir]
        running: true
    }

    FileView {
        id: file
        path: root.dataDir + "/frecency.json"
        atomicWrites: true
        onLoaded: {
            try { root.table = JSON.parse(text()) }
            catch (e) { root.table = {} }
        }
        onLoadFailed: root.table = {}
    }
}

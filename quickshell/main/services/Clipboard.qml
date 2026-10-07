pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// Clipboard
// Thin wrapper over `cliphist` + `wl-copy`. Needs the history writer running:
//   exec-once = wl-paste --type text  --watch cliphist store
//   exec-once = wl-paste --type image --watch cliphist store
// Items: [{ id, line, text }] newest first. `line` is the raw cliphist row,
// which `cliphist delete` expects on stdin.
// ============================================================================

Singleton {
    id: root

    property var items: []

    function refresh() { if (!listProc.running) listProc.running = true }

    function copy(id) {
        Quickshell.execDetached(["sh", "-c", 'cliphist decode "$1" | wl-copy', "sh", id])
    }

    function remove(item) {
        Quickshell.execDetached(["sh", "-c", 'printf "%s\\n" "$1" | cliphist delete', "sh", item.line])
        items = items.filter(x => x.id !== item.id)
    }

    function _parse(text) {
        const out = []
        for (const l of text.split("\n")) {
            const t = l.indexOf("\t")
            if (!l || t < 0) continue
            const body = l.slice(t + 1).trim()
            out.push({ id: l.slice(0, t), line: l, text: body === "" ? "(whitespace)" : body })
        }
        items = out
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector { onStreamFinished: root._parse(text) }
    }
}

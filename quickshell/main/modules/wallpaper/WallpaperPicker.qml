import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"

// ============================================================================
// WallpaperPicker — horizontal thumbnail carousel for ~/walls/current (awww).
//   qs -c main ipc call wallpaper toggle | random | next | prev
//
// In the picker: type to filter by file name; ←/→, ↑/↓, Ctrl+N / Ctrl+P (or
// Ctrl+J / Ctrl+K) move; Enter or clicking the centered one sets it; clicking
// a side one centers it; Ctrl+R random (within the current results); Ctrl+W
// deletes a word; Esc closes.
// ============================================================================

Scope {
    id: picker

    readonly property bool shown: Panels.current === "wallpaper"
    property string query: ""
    property int sel: 0
    property bool followCurrent: false      // keep the cursor on the active wallpaper until the user moves

    // all words in the query must appear in the file name
    readonly property var results: {
        const terms = query.trim().toLowerCase().split(/\s+/).filter(t => t !== "")
        const all = Wallpapers.files
        if (terms.length === 0) return all
        return all.filter(f => {
            const n = f.name.toLowerCase()
            return terms.every(t => n.indexOf(t) >= 0)
        })
    }

    readonly property var selected: results[sel] ? results[sel] : null
    readonly property string selectedName: selected ? selected.name : ""

    function indexInResults() {
        for (let i = 0; i < results.length; i++) if (Wallpapers.isCurrent(results[i].path)) return i
        return -1
    }

    onShownChanged: {
        if (shown) {
            win.resetInput()
            query = ""
            Wallpapers.refresh()
            followCurrent = true
            sel = Math.max(0, indexInResults())
        }
    }

    onQueryChanged: {
        followCurrent = query.trim() === ""
        sel = followCurrent ? Math.max(0, indexInResults()) : 0
    }

    onResultsChanged: {
        if (sel >= results.length) sel = Math.max(0, results.length - 1)
    }

    function syncSel() {
        if (shown && followCurrent) sel = Math.max(0, indexInResults())
    }

    Connections {
        target: Wallpapers
        function onCurrentChanged() { picker.syncSel() }
    }

    // wraps around at both ends
    function move(d) {
        const n = results.length
        if (n === 0) return
        followCurrent = false
        sel = (sel + d + n) % n
    }

    function select(i) {
        followCurrent = false
        sel = Math.max(0, Math.min(results.length - 1, i))
    }

    function activate() {
        if (!selected) return
        Wallpapers.apply(selected.path)
        close()
    }

    function randomize() {
        followCurrent = true            // cursor follows the new pick
        Wallpapers.random(query.trim() === "" ? null : results)
    }

    function close() { Panels.close("wallpaper") }

    WallpaperWindow { id: win; picker: picker }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void { Panels.toggle("wallpaper") }
        function random(): void { Wallpapers.random() }
        function next(): void { Wallpapers.step(1) }
        function prev(): void { Wallpapers.step(-1) }
    }
}

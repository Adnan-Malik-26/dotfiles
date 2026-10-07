import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"

// ============================================================================
// WallpaperPicker — thumbnail grid for ~/walls/current (set via awww).
//   qs -c main ipc call wallpaper toggle | random | next | prev
// In the picker:  arrows / hjkl move, Enter or click sets it and closes,
// R picks a random one and stays open, Esc closes.
// ============================================================================

Scope {
    id: picker

    readonly property bool shown: Panels.current === "wallpaper"
    property int sel: 0
    property bool followCurrent: false      // keep the cursor on the active wallpaper until the user moves

    readonly property string selectedName:
        Wallpapers.files[sel] ? Wallpapers.files[sel].name : ""

    onSelChanged: win.ensureVisible(sel)

    onShownChanged: {
        if (shown) {
            Wallpapers.refresh()
            followCurrent = true
            sel = Math.max(0, Wallpapers.indexOfCurrent())
        }
    }

    function syncSel() {
        if (shown && followCurrent) sel = Math.max(0, Wallpapers.indexOfCurrent())
    }

    Connections {
        target: Wallpapers
        function onFilesChanged() { picker.syncSel() }
        function onCurrentChanged() { picker.syncSel() }
    }

    function move(d) {
        const n = Wallpapers.files.length
        if (n === 0) return
        followCurrent = false
        sel = Math.max(0, Math.min(n - 1, sel + d))
    }

    function activate() {
        const f = Wallpapers.files[sel]
        if (!f) return
        Wallpapers.apply(f.path)
        close()
    }

    function randomize() {
        followCurrent = true        // cursor follows the new pick
        Wallpapers.random()
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

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// Wallpapers
// Lists images in ~/walls/current and sets them through awww (the daemon,
// `awww-daemon`, must already be running — start it from hyprland.conf).
//
// awww does NOT remember the wallpaper across daemon restarts, so the last
// choice is saved to ~/.local/state/quickshell/wallpaper and re-applied once
// at startup (only if the daemon isn't already showing an image — so hot
// reloads, or a restore script of your own, are left alone). Turn off with
// `restoreOnStart: false`.
//
// Thumbnails are NOT generated here: the picker lets Qt decode each visible
// image at reduced size. Fine for dozens of wallpapers; see README for the
// on-disk cache upgrade if the folder gets big.
// ============================================================================

Singleton {
    id: root

    // ---- config ----
    readonly property string dir: Quickshell.env("HOME") + "/walls/current"
    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/quickshell"
    readonly property string stateFile: stateDir + "/wallpaper"
    readonly property var extensions: ["png", "jpg", "jpeg", "webp", "gif", "bmp", "svg"]   // what Qt can thumbnail
    property string transition: "grow"      // awww --transition-type
    property int transitionFps: 60          // awww --transition-fps
    property bool restoreOnStart: true

    // ---- state ----
    property var files: []                  // [{ path, name }], sorted by name
    property string current: ""             // path of the wallpaper in use
    property bool _restored: false

    // ---- helpers ----
    function nameOf(p) { return p.substring(p.lastIndexOf("/") + 1) }

    // awww may report a canonical path (e.g. if ~/walls/current is a symlink),
    // so fall back to comparing file names.
    function isCurrent(path) {
        return current !== "" && (current === path || nameOf(current) === nameOf(path))
    }

    function indexOfCurrent() {
        for (let i = 0; i < files.length; i++) if (isCurrent(files[i].path)) return i
        return -1
    }

    // percent-encode each path segment so spaces, '#' and '?' survive as a URL
    function fileUrl(p) { return "file://" + p.split("/").map(encodeURIComponent).join("/") }

    // ---- actions ----
    function refresh() {
        if (!scanProc.running) scanProc.running = true
        if (!queryProc.running) queryProc.running = true
    }

    function apply(path) {
        if (!path) return
        current = path
        Quickshell.execDetached([
            "sh", "-c",
            'awww img "$1" --transition-type "$2" --transition-fps "$3" || '
                + 'notify-send -a wallpaper -u critical "Wallpaper" "awww failed — is awww-daemon running?"',
            "sh", path, transition, String(transitionFps)
        ])
        stateFile_.setText(path)
    }

    // random wallpaper (never the current one if there's a choice); `pool` optionally
    // restricts the choice, e.g. to the picker's search results
    function random(pool) {
        const src = pool && pool.length > 0 ? pool : files
        if (src.length === 0) return ""
        let candidates = src.filter(f => !isCurrent(f.path))
        if (candidates.length === 0) candidates = src
        const f = candidates[Math.floor(Math.random() * candidates.length)]
        apply(f.path)
        return f.path
    }

    function step(dir) {
        if (files.length === 0) return
        const i = indexOfCurrent()
        apply(files[i < 0 ? 0 : (i + dir + files.length) % files.length].path)
    }

    Component.onCompleted: refresh()

    // ---- scan the folder ----
    readonly property string _findScript:
        'find -L "$1" -maxdepth 1 -type f \\( '
        + extensions.map(e => '-iname "*.' + e + '"').join(' -o ')
        + ' \\) | sort -f'

    Process {
        id: scanProc
        command: ["sh", "-c", root._findScript, "sh", root.dir]
        stdout: StdioCollector { onStreamFinished: root._parseFiles(text) }
    }

    function _parseFiles(text) {
        const out = []
        for (const l of text.split("\n")) {
            if (l !== "") out.push({ path: l, name: nameOf(l) })
        }
        files = out
    }

    // ---- what is displayed right now (awww query: "... currently displaying: image: /path") ----
    Process {
        id: queryProc
        command: ["awww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.match(/image:\s*(.+)$/m)
                if (m) root.current = m[1].trim()
            }
        }
    }

    // ---- persistence + restore ----
    Process {
        command: ["mkdir", "-p", root.stateDir]
        running: true
    }

    FileView {
        id: stateFile_
        path: root.stateFile
        atomicWrites: true
        onLoaded: {
            const p = text().trim()
            if (p === "") return
            if (root.current === "") root.current = p
            if (root.restoreOnStart && !root._restored) {
                root._restored = true
                // wait (<= 15 s) for the daemon, then set the saved image unless
                // something is already on screen. step 255 = effectively instant.
                Quickshell.execDetached([
                    "sh", "-c",
                    'f="$1"; for i in $(seq 1 30); do awww query >/dev/null 2>&1 && break; sleep 0.5; done; '
                        + 'awww query 2>/dev/null | grep -q "image:" && exit 0; '
                        + '[ -f "$f" ] && awww img "$f" --transition-type simple --transition-step 255',
                    "sh", p
                ])
            }
        }
    }
}

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "config.js" as Config

// ============================================================================
// WifiManager
// Talks to NetworkManager exclusively through `nmcli`, same as
// Brightness.qml talks to brightnessctl. There IS a native
// Quickshell.Networking module (NetworkManager over DBus) as of recent
// Quickshell releases, but its WiFi/AccessPoint API isn't stable or
// documented well enough yet to build against without guessing property
// names — shelling out to nmcli is slower and text-parsing is uglier, but
// it's a stable contract. Swap this singleton's internals for the native
// DBus service once you've confirmed its API against your installed
// Quickshell version; nothing outside this file needs to change.
//
// Every nmcli call below passes argv as a real array (Process.command),
// NOT a "sh -c" string built by concatenation — so an SSID containing
// `; rm -rf ~` is just a literal argument, never shell syntax. Don't
// "simplify" this into `["sh", "-c", "nmcli ... " + ssid]` for readability;
// that reintroduces command injection from anything nmcli echoes back
// verbatim (SSIDs are attacker-controlled if you're near a rogue AP).
// ============================================================================

Singleton {
    id: root

    property bool available: true       // false if `nmcli` isn't on PATH
    property bool enabled: false         // WiFi radio on/off
    property bool scanning: false
    property var networks: []            // [{ssid, signal, secured, active, saved}]
    property string connectingSsid: ""   // "" when nothing is mid-connect
    property string lastError: ""

    readonly property var activeNetwork: {
        for (const n of networks) if (n.active) return n
        return null
    }

    function refreshRadioState() { radioProc.running = true }
    function refreshNetworks() { listProc.running = true; savedProc.running = true }

    function toggleRadio() {
        toggleRadioProc.command = ["nmcli", "radio", "wifi", root.enabled ? "off" : "on"]
        toggleRadioProc.running = true
    }

    function rescan() {
        if (!root.enabled) return
        root.scanning = true
        rescanProc.running = true
        scanBurstTimer.restart()
    }

    function connectToNetwork(ssid, password) {
        root.lastError = ""
        root.connectingSsid = ssid
        const cmd = ["nmcli", "device", "wifi", "connect", ssid]
        if (password && password.length > 0) cmd.push("password", password)
        connectProc.command = cmd
        connectProc.running = true
        connectTimeoutTimer.restart()
    }

    function disconnectNetwork(ssid) {
        disconnectProc.command = ["nmcli", "connection", "down", ssid]
        disconnectProc.running = true
    }

    // Assumes the saved connection profile is named after its SSID, which
    // is nmcli's default when you connect via `device wifi connect`. If
    // you've since renamed the profile (or auto-generated ones collide,
    // e.g. two different networks both called "extender"), this deletes
    // the wrong one — resolve by connection UUID instead if that matters
    // to you, via `nmcli -t -f NAME,UUID connection show`.
    function forgetNetwork(ssid) {
        forgetProc.command = ["nmcli", "connection", "delete", ssid]
        forgetProc.running = true
    }

    Component.onCompleted: {
        checkAvailProc.running = true
    }

    Timer {
        id: pollTimer
        interval: Config.timeout.scanInterval
        running: root.available && root.enabled
        repeat: true
        onTriggered: root.refreshNetworks()
    }

    Timer {
        id: scanBurstTimer
        interval: Config.timeout.scanBurst
        repeat: false
        onTriggered: root.scanning = false
    }

    Timer {
        id: connectTimeoutTimer
        interval: Config.timeout.connectTimeout
        repeat: false
        onTriggered: root.connectingSsid = ""
    }

    // ---- one-shot availability probe ----------------------------------
    Process {
        id: checkAvailProc
        command: ["sh", "-c", "command -v nmcli >/dev/null 2>&1 && echo yes || echo no"]
        stdout: SplitParser {
            onRead: line => {
                root.available = line.trim() === "yes"
                if (root.available) {
                    root.refreshRadioState()
                    root.refreshNetworks()
                }
            }
        }
    }

    // ---- radio state ----------------------------------------------------
    Process {
        id: radioProc
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser {
            onRead: line => { root.enabled = line.trim() === "enabled" }
        }
    }

    Process {
        id: toggleRadioProc
        onExited: root.refreshRadioState()
    }

    // ---- scan trigger (best-effort; nmcli rate-limits real rescans) ----
    Process {
        id: rescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onExited: root.refreshNetworks()
    }

    // ---- network list ----------------------------------------------------
    // Terse mode (-t) is machine-readable: fields are colon-separated and
    // any literal `:` or `\` inside a field is backslash-escaped by nmcli
    // itself. splitTerseLine undoes that — a naive line.split(":") breaks
    // on the first SSID containing a colon.
    function splitTerseLine(line) {
        const parts = []
        let current = ""
        for (let i = 0; i < line.length; i++) {
            if (line[i] === "\\" && i + 1 < line.length) {
                current += line[i + 1]
                i++
            } else if (line[i] === ":") {
                parts.push(current)
                current = ""
            } else {
                current += line[i]
            }
        }
        parts.push(current)
        return parts
    }

    property var _savedNames: []

    Process {
        id: savedProc
        command: ["nmcli", "-t", "-f", "NAME", "connection", "show"]
        property var names: []
        running: false
        onRunningChanged: if (running) names = []
        stdout: SplitParser {
            onRead: line => { if (line.trim() !== "") savedProc.names.push(line.trim()) }
        }
        onExited: root._savedNames = names
    }

    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
        property var rows: []
        running: false
        onRunningChanged: if (running) rows = []
        stdout: SplitParser {
            onRead: line => {
                if (line.trim() === "") return
                const f = root.splitTerseLine(line)
                if (f.length < 4 || f[1] === "") return  // skip hidden/blank SSIDs
                listProc.rows.push({
                    active: f[0] === "yes",
                    ssid: f[1],
                    signal: parseInt(f[2]) || 0,
                    secured: f[3] !== "" && f[3] !== "--"
                })
            }
        }
        onExited: {
            // Dedupe by SSID (same network, multiple APs/BSSIDs), keep
            // strongest signal; nmcli already sorts by signal so first
            // occurrence wins.
            const seen = new Set()
            const deduped = []
            for (const r of listProc.rows) {
                if (seen.has(r.ssid)) continue
                seen.add(r.ssid)
                deduped.push({
                    active: r.active,
                    ssid: r.ssid,
                    signal: r.signal,
                    secured: r.secured,
                    saved: root._savedNames.includes(r.ssid)
                })
            }
            root.networks = deduped
            root.scanning = false
        }
    }

    // ---- connect / disconnect / forget ----------------------------------
    Process {
        id: connectProc
        property string stderrBuf: ""
        stderr: SplitParser { onRead: line => connectProc.stderrBuf += line + "\n" }
        onExited: exitCode => {
            root.connectingSsid = ""
            connectTimeoutTimer.stop()
            if (exitCode !== 0) root.lastError = connectProc.stderrBuf.trim() || "Connection failed"
            root.refreshNetworks()
        }
    }

    Process {
        id: disconnectProc
        onExited: root.refreshNetworks()
    }

    Process {
        id: forgetProc
        onExited: root.refreshNetworks()
    }
}

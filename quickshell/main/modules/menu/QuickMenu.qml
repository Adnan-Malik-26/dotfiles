import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"

// ============================================================================
// QuickMenu — one overlay, three modes: apps / clipboard / power.
// Every mode produces a list of { kind, key, title, sub, ... } items; one
// activate() dispatches on `kind`, so a new mode = a data source + a filter.
//
//   qs -c main ipc call menu toggle apps|clipboard|power
//   qs -c main ipc call menu open   apps|clipboard|power
//   qs -c main ipc call menu close
//
// Clipboard needs:  wl-paste --type text/image --watch cliphist store
// Power commands assume Hyprland (hyprlock, hyprctl) — edit powerItems.
// ============================================================================

Scope {
    id: root

    readonly property var modes: ["apps", "clipboard", "power"]
    readonly property var powerItems: [
        { kind: "power", key: "lock",     title: "Lock",      sub: "hyprlock",           cmd: ["hyprlock"],                    danger: false },
        { kind: "power", key: "suspend",  title: "Suspend",   sub: "systemctl suspend",  cmd: ["systemctl", "suspend"],        danger: false },
        { kind: "power", key: "logout",   title: "Log out",   sub: "exit Hyprland",      cmd: ["hyprctl", "dispatch", "exit"], danger: true },
        { kind: "power", key: "reboot",   title: "Reboot",    sub: "systemctl reboot",   cmd: ["systemctl", "reboot"],         danger: true },
        { kind: "power", key: "shutdown", title: "Shut down", sub: "systemctl poweroff", cmd: ["systemctl", "poweroff"],       danger: true }
    ]

    // ---------- state ----------
    readonly property bool shown: Panels.current === "menu"
    property string mode: "apps"
    property string query: ""
    property int sel: 0
    property string armed: ""          // power item awaiting a second Enter

    onQueryChanged: { sel = 0; armed = ""; }
    onModeChanged: { sel = 0; armed = ""; }
    onSelChanged: { armed = ""; win.ensureVisible(sel); }

    // ---------- data ----------
    readonly property var appItems: {
        var vals = DesktopEntries.applications.values, out = [];
        for (var i = 0; i < vals.length; i++) {
            var e = vals[i];
            if (e.noDisplay) continue;
            out.push({
                kind: "app", key: "app:" + e.id, title: e.name,
                sub: e.comment || e.genericName || "", entry: e
            });
        }
        out.sort(function (a, b) { return a.title.toLowerCase() < b.title.toLowerCase() ? -1 : 1; });
        return out;
    }

    function fuzzy(q, text) {
        if (!q) return 0;
        var t = (text || "").toLowerCase(), i = t.indexOf(q);
        if (i === 0) return 100;
        if (i > 0) return t.charAt(i - 1) === " " ? 80 : 60;
        var qi = 0;                                   // subsequence fallback
        for (var k = 0; k < t.length && qi < q.length; k++)
            if (t.charAt(k) === q.charAt(qi)) qi++;
        return qi === q.length ? 20 : -1;
    }

    readonly property var results: {
        var q = query.trim().toLowerCase(), out = [], i;
        if (mode === "apps") {
            var scored = [];
            for (i = 0; i < appItems.length; i++) {
                var it = appItems[i];
                var s = fuzzy(q, it.title);
                if (s < 0 && q && it.sub && fuzzy(q, it.sub) >= 60) s = 10;
                if (s >= 0) scored.push({ s: s + Frecency.score(it.entry.id), it: it });
            }
            scored.sort(function (a, b) {
                return (b.s - a.s) || (a.it.title.toLowerCase() < b.it.title.toLowerCase() ? -1 : 1);
            });
            for (i = 0; i < scored.length && i < 100; i++) out.push(scored[i].it);
        } else if (mode === "clipboard") {
            var clips = Clipboard.items;
            for (i = 0; i < clips.length && out.length < 100; i++) {
                if (q && clips[i].text.toLowerCase().indexOf(q) < 0) continue;
                out.push({ kind: "clip", key: "clip:" + clips[i].id, id: clips[i].id,
                           line: clips[i].line, title: clips[i].text, sub: "" });
            }
        } else {
            for (i = 0; i < powerItems.length; i++)
                if (!q || powerItems[i].title.toLowerCase().indexOf(q) >= 0) out.push(powerItems[i]);
        }
        return out;
    }

    // ---------- actions ----------
    function openMenu(m) {
        mode = m;
        win.resetInput();
        query = "";
        sel = 0;
        armed = "";
        if (m === "clipboard") Clipboard.refresh();
        Panels.open("menu");
    }

    function setMode(m) {
        mode = m;
        win.resetInput();
        query = "";
        if (m === "clipboard") Clipboard.refresh();
        win.focusInput();
    }

    function cycleMode(dir) {
        var i = modes.indexOf(mode);
        setMode(modes[(i + dir + modes.length) % modes.length]);
    }

    function close() { Panels.close("menu"); }

    function move(d) {
        var n = results.length;
        if (n === 0) return;
        sel = (sel + d + n) % n;
    }

    function activate() {
        var it = results[sel];
        if (!it) return;
        if (it.danger && armed !== it.key) { armed = it.key; return; }   // confirm destructive actions
        if (it.kind === "app") { Frecency.record(it.entry.id); it.entry.execute(); }
        else if (it.kind === "clip") Clipboard.copy(it.id);
        else Quickshell.execDetached(it.cmd);
        close();
    }

    function deleteClip() {
        var it = results[sel];
        if (!it || it.kind !== "clip") return;
        Clipboard.remove(it);
        sel = Math.min(sel, Math.max(0, results.length - 1));
    }

    QuickMenuWindow { id: win; menu: root }

    IpcHandler {
        target: "menu"
        function open(mode: string): void { root.openMenu(mode); }
        function toggle(mode: string): void {
            if (root.shown && root.mode === mode) root.close();
            else root.openMenu(mode);
        }
        function close(): void { root.close(); }
    }
}

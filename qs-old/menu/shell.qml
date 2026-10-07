import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // ---------- config ----------
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property var modes: ["apps", "clipboard", "power"]
    readonly property var powerItems: [
        { kind: "power", key: "lock",     title: "Lock",     sub: "hyprlock",           cmd: ["hyprlock"],                       danger: false },
        { kind: "power", key: "suspend",  title: "Suspend",  sub: "systemctl suspend",  cmd: ["systemctl", "suspend"],           danger: false },
        { kind: "power", key: "logout",   title: "Log out",  sub: "exit Hyprland",      cmd: ["hyprctl", "dispatch", "exit"],    danger: true },
        { kind: "power", key: "reboot",   title: "Reboot",   sub: "systemctl reboot",   cmd: ["systemctl", "reboot"],            danger: true },
        { kind: "power", key: "shutdown", title: "Shut down", sub: "systemctl poweroff", cmd: ["systemctl", "poweroff"],         danger: true }
    ]

    // ---------- state ----------
    property bool shown: false
    property string mode: "apps"
    property string query: ""
    property int sel: 0
    property string armed: ""          // power item awaiting a second Enter
    property var clipItems: []
    property var frecency: ({})       // { appId: { count, last } }
    readonly property string dataDir: Quickshell.env("HOME") + "/.local/share/quickshell/menu"

    onQueryChanged: { sel = 0; armed = ""; }
    onModeChanged: { sel = 0; armed = ""; }
    onSelChanged: { armed = ""; list.positionViewAtIndex(sel, ListView.Contain); }

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

    // Firefox-style frecency: launch count weighted by how recently it was used.
    // Bonus is capped so a strong text match still beats a merely popular app.
    function frecencyScore(id) {
        var r = frecency[id];
        if (!r) return 0;
        var h = 3600000, age = Date.now() - r.last;
        var w = age < h ? 4 : age < 24 * h ? 2 : age < 7 * 24 * h ? 0.5 : 0.25;
        return Math.min(25, 6 * Math.log(1 + r.count * w) / Math.LN2);
    }

    function recordLaunch(id) {
        var f = JSON.parse(JSON.stringify(frecency));
        f[id] = { count: (f[id] ? f[id].count : 0) + 1, last: Date.now() };
        frecency = f;
        frecencyFile.setText(JSON.stringify(f, null, 1));
    }

    readonly property var results: {
        var q = query.trim().toLowerCase(), out = [], i;
        if (mode === "apps") {
            var scored = [];
            for (i = 0; i < appItems.length; i++) {
                var it = appItems[i];
                var s = fuzzy(q, it.title);
                if (s < 0 && q && it.sub && fuzzy(q, it.sub) >= 60) s = 10;
                if (s >= 0) scored.push({ s: s + frecencyScore(it.entry.id), it: it });
            }
            scored.sort(function (a, b) {
                return (b.s - a.s) || (a.it.title.toLowerCase() < b.it.title.toLowerCase() ? -1 : 1);
            });
            for (i = 0; i < scored.length && i < 100; i++) out.push(scored[i].it);
        } else if (mode === "clipboard") {
            for (i = 0; i < clipItems.length && out.length < 100; i++)
                if (!q || clipItems[i].title.toLowerCase().indexOf(q) >= 0) out.push(clipItems[i]);
        } else {
            for (i = 0; i < powerItems.length; i++)
                if (!q || powerItems[i].title.toLowerCase().indexOf(q) >= 0) out.push(powerItems[i]);
        }
        return out;
    }

    function parseClip(text) {
        var out = [], lines = text.split("\n");
        for (var i = 0; i < lines.length; i++) {
            var l = lines[i], t = l.indexOf("\t");
            if (!l || t < 0) continue;
            var title = l.slice(t + 1).trim();
            out.push({
                kind: "clip", key: "clip:" + l.slice(0, t), id: l.slice(0, t), line: l,
                title: title === "" ? "(whitespace)" : title, sub: ""
            });
        }
        clipItems = out;
    }

    function loadClip() { if (!clipList.running) clipList.running = true; }

    // ---------- actions ----------
    function openMenu(m) {
        mode = m;
        input.text = "";
        query = "";
        sel = 0;
        armed = "";
        if (m === "clipboard") loadClip();
        shown = true;
    }

    function setMode(m) {
        mode = m;
        input.text = "";
        query = "";
        if (m === "clipboard") loadClip();
        input.forceActiveFocus();
    }

    function cycleMode(dir) {
        var i = modes.indexOf(mode);
        setMode(modes[(i + dir + modes.length) % modes.length]);
    }

    function move(d) {
        var n = results.length;
        if (n === 0) return;
        sel = (sel + d + n) % n;
    }

    function activate() {
        var it = results[sel];
        if (!it) return;
        if (it.danger && armed !== it.key) { armed = it.key; return; }   // confirm destructive actions
        if (it.kind === "app") { recordLaunch(it.entry.id); it.entry.execute(); }
        else if (it.kind === "clip")
            Quickshell.execDetached(["sh", "-c", 'cliphist decode "$1" | wl-copy', "sh", it.id]);
        else Quickshell.execDetached(it.cmd);
        shown = false;
    }

    function deleteClip() {
        var it = results[sel];
        if (!it || it.kind !== "clip") return;
        Quickshell.execDetached(["sh", "-c", 'printf "%s\\n" "$1" | cliphist delete', "sh", it.line]);
        clipItems = clipItems.filter(function (x) { return x.id !== it.id; });
        sel = Math.min(sel, Math.max(0, results.length - 1));
    }

    // ---------- plumbing ----------
    Process {
        command: ["mkdir", "-p", root.dataDir]
        running: true
    }

    FileView {
        id: frecencyFile
        path: root.dataDir + "/frecency.json"
        atomicWrites: true
        onLoaded: {
            try { root.frecency = JSON.parse(text()); }
            catch (e) { root.frecency = {}; }
        }
        onLoadFailed: root.frecency = {}
    }

    Process {
        id: clipList
        command: ["cliphist", "list"]
        stdout: StdioCollector { onStreamFinished: root.parseClip(text) }
    }

    // qs -c menu ipc call menu toggle apps|clipboard|power
    IpcHandler {
        target: "menu"
        function open(mode: string): void { root.openMenu(mode); }
        function toggle(mode: string): void {
            if (root.shown && root.mode === mode) root.shown = false;
            else root.openMenu(mode);
        }
        function close(): void { root.shown = false; }
    }

    // ---------- window: fullscreen transparent overlay, card centered ----------
    PanelWindow {
        id: win
        visible: root.shown
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "menu"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        onVisibleChanged: {
            if (visible) {
                intro.restart();
                Qt.callLater(function () { input.forceActiveFocus(); });
            }
        }

        // click outside the card closes
        MouseArea {
            anchors.fill: parent
            onClicked: root.shown = false
        }
        Rectangle {
            id: backdrop
            anchors.fill: parent
            color: "#66000000"
            z: -1
        }

        Rectangle {
            id: card
            width: 560
            height: 440
            anchors.centerIn: parent
            radius: 18
            color: "#0e0e0e"
            border.color: "#2a2a2a"

            ParallelAnimation {
                id: intro
                NumberAnimation { target: card; property: "opacity"; from: 0; to: 1; duration: 160; easing.type: Easing.OutCubic }
                NumberAnimation { target: card; property: "scale"; from: 0.97; to: 1; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { target: backdrop; property: "opacity"; from: 0; to: 1; duration: 200 }
            }

            MouseArea { anchors.fill: parent }   // swallow clicks on the card

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // mode chips
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: root.modes
                        Chip {
                            required property string modelData
                            label: modelData
                            active: root.mode === modelData
                            onClicked: root.setMode(modelData)
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.results.length + (root.results.length === 1 ? " result" : " results")
                        color: "#555555"
                        font.family: root.fontFamily
                        font.pixelSize: 11
                    }
                }

                // search
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 42
                    radius: 10
                    color: "#161616"
                    border.color: "#2a2a2a"

                    TextInput {
                        id: input
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        verticalAlignment: TextInput.AlignVCenter
                        color: "#e6e6e6"
                        font.family: root.fontFamily
                        font.pixelSize: 15
                        clip: true
                        focus: true
                        selectByMouse: true
                        onTextChanged: root.query = text

                        Keys.onPressed: function (e) {
                            var ctrl = e.modifiers & Qt.ControlModifier;
                            if (e.key === Qt.Key_Escape) {
                                root.shown = false; e.accepted = true;
                            } else if (e.key === Qt.Key_Down || (ctrl && (e.key === Qt.Key_N || e.key === Qt.Key_J))) {
                                root.move(1); e.accepted = true;
                            } else if (e.key === Qt.Key_Up || (ctrl && (e.key === Qt.Key_P || e.key === Qt.Key_K))) {
                                root.move(-1); e.accepted = true;
                            } else if (e.key === Qt.Key_Tab) {
                                root.cycleMode(1); e.accepted = true;
                            } else if (e.key === Qt.Key_Backtab) {
                                root.cycleMode(-1); e.accepted = true;
                            } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                root.activate(); e.accepted = true;
                            } else if (ctrl && e.key === Qt.Key_W) {
                                var p = input.cursorPosition, t = input.text, i = p;
                                while (i > 0 && t.charAt(i - 1) === " ") i--;
                                while (i > 0 && t.charAt(i - 1) !== " ") i--;
                                input.remove(i, p);
                                e.accepted = true;
                            } else if (ctrl && e.key === Qt.Key_D && root.mode === "clipboard") {
                                root.deleteClip(); e.accepted = true;
                            }
                        }

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: !input.text.length
                            text: root.mode === "apps" ? "Search applications…"
                                : root.mode === "clipboard" ? "Search clipboard…" : "Filter actions…"
                            color: "#555555"
                            font.family: root.fontFamily
                            font.pixelSize: 15
                        }
                    }
                }

                // results
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    model: root.results
                    currentIndex: root.sel
                    boundsBehavior: Flickable.StopAtBounds

                    Text {
                        anchors.centerIn: parent
                        visible: root.results.length === 0
                        horizontalAlignment: Text.AlignHCenter
                        text: root.mode === "clipboard" && root.clipItems.length === 0
                            ? "clipboard history is empty\nneeds: wl-paste --watch cliphist store"
                            : "no matches"
                        color: "#555555"
                        font.family: root.fontFamily
                        font.pixelSize: 12
                    }

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool selected: index === root.sel
                        readonly property bool isArmed: root.armed === modelData.key

                        width: list.width
                        height: 46
                        radius: 9
                        color: isArmed ? "#e6e6e6" : (selected ? "#1c1c1c" : "transparent")
                        border.color: selected && !isArmed ? "#2f2f2f" : "transparent"
                        Behavior on color { ColorAnimation { duration: 90 } }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onPositionChanged: if (root.sel !== row.index) root.sel = row.index
                            onClicked: { root.sel = row.index; root.activate(); }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Column {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    width: parent.width
                                    elide: Text.ElideRight
                                    text: row.isArmed ? "Press Enter again to confirm" : row.modelData.title
                                    color: row.isArmed ? "#0e0e0e" : (row.selected ? "#e6e6e6" : "#b0b0b0")
                                    font.family: root.fontFamily
                                    font.pixelSize: 14
                                }
                                Text {
                                    width: parent.width
                                    elide: Text.ElideRight
                                    visible: text.length > 0 && !row.isArmed
                                    text: row.modelData.sub || ""
                                    color: "#6b6b6b"
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }

                // footer hints
                Text {
                    Layout.fillWidth: true
                    text: root.mode === "clipboard" ? "↑↓ select · ⏎ copy · Ctrl+D delete · Tab mode · Esc close"
                        : root.mode === "power" ? "↑↓ select · ⏎ run (twice for destructive) · Tab mode · Esc close"
                        : "↑↓ select · ⏎ launch · Tab mode · Esc close"
                    color: "#555555"
                    font.family: root.fontFamily
                    font.pixelSize: 11
                }
            }
        }
    }
}

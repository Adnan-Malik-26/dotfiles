import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // ---------- palette (monochrome) ----------
    readonly property color bg: "#0e0e0e"
    readonly property color surface: "#161616"
    readonly property color line: "#2a2a2a"
    readonly property color dim: "#6b6b6b"
    readonly property color fg: "#e8e8e8"

    // ---------- state ----------
    property bool shown: true
    property string view: "timer"
    property int minutes: 25
    property int total: minutes * 60
    property int remaining: total
    property string tag: ""
    property bool running: false
    property double endAt: 0
    property double startedAt: 0
    property var sessions: []

    readonly property string dataDir: Quickshell.env("HOME") + "/.local/share/pomodoro"
    readonly property var recent: (function () {
        var seen = [];
        for (var i = sessions.length - 1; i >= 0 && seen.length < 5; i--) {
            var t = sessions[i].tag;
            if (seen.indexOf(t) < 0) seen.push(t);
        }
        return seen;
    })()

    // ---------- logic ----------
    function setMinutes(m) {
        if (running || !(m > 0)) return;
        minutes = m;
        total = m * 60;
        remaining = total;
    }

    function start() {
        if (remaining <= 0) remaining = total;
        endAt = Date.now() + remaining * 1000;
        if (startedAt === 0) startedAt = Date.now();
        running = true;
    }

    function pause() {
        remaining = Math.max(0, Math.ceil((endAt - Date.now()) / 1000));
        running = false;
    }

    function reset() {
        running = false;
        startedAt = 0;
        remaining = total;
    }

    function finish() {
        running = false;
        var entry = {
            tag: tag.trim() === "" ? "untagged" : tag.trim(),
            minutes: minutes,
            startedAt: startedAt,
            endedAt: Date.now()
        };
        sessions = sessions.concat([entry]);
        store.setText(JSON.stringify(sessions, null, 1));
        notifier.command = ["notify-send", "-a", "pomodoro", "Session done", entry.tag + " · " + minutes + "m"];
        notifier.running = true;
        chime.running = true;
        startedAt = 0;
        remaining = total;
    }

    function fmt(s) {
        var m = Math.floor(s / 60), r = s % 60;
        return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r;
    }

    function todayStats() {
        var day = new Date().toDateString(), mins = 0, n = 0;
        for (var i = 0; i < sessions.length; i++) {
            if (new Date(sessions[i].startedAt).toDateString() === day) {
                mins += sessions[i].minutes;
                n++;
            }
        }
        return n + " sessions · " + Math.floor(mins / 60) + "h " + (mins % 60) + "m today";
    }

    // ---------- stats ----------
    function dayKey(d) { return d.getFullYear() + "-" + d.getMonth() + "-" + d.getDate(); }
    function fmtMins(m) { return m < 60 ? m + "m" : Math.floor(m / 60) + "h " + (m % 60) + "m"; }
    function fmtShort(m) { return m < 60 ? m + "m" : (m / 60).toFixed(1) + "h"; }

    // last 7 days, oldest -> today
    readonly property var weekData: {
        var byDay = {}, out = [], names = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
        for (var i = 0; i < sessions.length; i++) {
            var k = dayKey(new Date(sessions[i].startedAt));
            byDay[k] = (byDay[k] || 0) + sessions[i].minutes;
        }
        var now = new Date();
        for (var j = 6; j >= 0; j--) {
            var d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - j);
            out.push({ label: names[d.getDay()], minutes: byDay[dayKey(d)] || 0, today: j === 0 });
        }
        return out;
    }

    readonly property int todayMinutes: weekData[6].minutes
    readonly property int weekMinutes: {
        var t = 0;
        for (var i = 0; i < weekData.length; i++) t += weekData[i].minutes;
        return t;
    }

    // consecutive days with >= 1 session; stays alive until the end of today
    readonly property int streak: {
        var days = {};
        for (var i = 0; i < sessions.length; i++) days[dayKey(new Date(sessions[i].startedAt))] = true;
        var n = new Date();
        var d = new Date(n.getFullYear(), n.getMonth(), n.getDate());
        if (!days[dayKey(d)]) d = new Date(d.getFullYear(), d.getMonth(), d.getDate() - 1);
        var count = 0;
        while (days[dayKey(d)]) {
            count++;
            d = new Date(d.getFullYear(), d.getMonth(), d.getDate() - 1);
        }
        return count;
    }

    // all-time per-tag totals, biggest first
    readonly property var tagTotals: {
        var m = {}, arr = [];
        for (var i = 0; i < sessions.length; i++) {
            var t = sessions[i].tag;
            if (!m[t]) m[t] = { tag: t, minutes: 0, count: 0 };
            m[t].minutes += sessions[i].minutes;
            m[t].count++;
        }
        for (var k in m) arr.push(m[k]);
        arr.sort(function (a, b) { return b.minutes - a.minutes; });
        return arr;
    }

    // ---------- plumbing ----------
    Process {
        command: ["mkdir", "-p", root.dataDir]
        running: true
    }
    Process { id: notifier }

    // Chime on completion. Silently skipped if the file is missing.
    // Needs mpv or ffplay (ffmpeg) installed for mp3 playback.
    Process {
        id: chime
        command: [
            "sh", "-c",
            'f="$1"; [ -f "$f" ] || exit 0; mpv --no-video --really-quiet "$f" || ffplay -nodisp -autoexit -loglevel quiet "$f"',
            "sh",
            Quickshell.env("HOME") + "/.local/share/quickshell/pomodoro/ding.mp3"
        ]
    }

    FileView {
        id: store
        path: root.dataDir + "/sessions.json"
        onLoaded: {
            try { root.sessions = JSON.parse(text()); }
            catch (e) { root.sessions = []; }
        }
        onLoadFailed: root.sessions = []
    }

    Timer {
        interval: 250
        repeat: true
        running: root.running
        onTriggered: {
            root.remaining = Math.max(0, Math.ceil((root.endAt - Date.now()) / 1000));
            if (root.remaining <= 0) root.finish();
        }
    }

    // qs -c pomodoro ipc call pomo toggle
    IpcHandler {
        target: "pomo"
        function toggle(): void { root.shown = !root.shown; }
        function show(): void { root.shown = true; }
        function hide(): void { root.shown = false; }
    }

    // ---------- window (no anchors => centered) ----------
    PanelWindow {
        id: win
        visible: root.shown
        implicitWidth: 420
        implicitHeight: 540
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "pomodoro"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        onVisibleChanged: if (visible) intro.restart()

        Rectangle {
            id: card
            anchors.fill: parent
            radius: 18
            color: root.bg
            border.color: root.line

            ParallelAnimation {
                id: intro
                running: true
                NumberAnimation { target: card; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
                NumberAnimation { target: card; property: "scale"; from: 0.96; to: 1; duration: 220; easing.type: Easing.OutCubic }
            }

            // Keyboard: Space start/pause, Ctrl+R reset, Tab switch tabs,
            // Esc leaves a text field first, then hides the window.
            // (Space is not intercepted while you're typing in a field.)
            Shortcut {
                sequence: "Escape"
                onActivated: (tagIn.activeFocus || minIn.activeFocus) ? card.forceActiveFocus() : root.shown = false
            }
            Shortcut { sequence: "Space"; onActivated: root.running ? root.pause() : root.start() }
            Shortcut { sequence: "Ctrl+R"; onActivated: root.reset() }
            Shortcut {
                sequence: "Tab"
                onActivated: {
                    card.forceActiveFocus();
                    var order = ["timer", "history", "stats"];
                    root.view = order[(order.indexOf(root.view) + 1) % order.length];
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                // header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Chip { label: "timer"; active: root.view === "timer"; onClicked: root.view = "timer" }
                    Chip { label: "history"; active: root.view === "history"; onClicked: root.view = "history" }
                    Chip { label: "stats"; active: root.view === "stats"; onClicked: root.view = "stats" }
                    Item { Layout.fillWidth: true }
                    Chip { label: "✕"; padding: 14; onClicked: root.shown = false }
                }

                // views live below the always-visible header
                Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // ---------- timer view ----------
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16
                    visible: opacity > 0
                    opacity: root.view === "timer" ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 230
                        implicitHeight: 230

                        Canvas {
                            id: ring
                            anchors.fill: parent
                            property real p: root.total > 0 ? 1 - root.remaining / root.total : 0
                            Behavior on p { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                            onPChanged: requestPaint()
                            onPaint: {
                                var c = getContext("2d");
                                c.reset();
                                var r = width / 2 - 8, cx = width / 2, cy = height / 2;
                                c.lineWidth = 4;
                                c.lineCap = "round";
                                c.strokeStyle = "#2a2a2a";
                                c.beginPath(); c.arc(cx, cy, r, 0, 2 * Math.PI); c.stroke();
                                if (p > 0) {
                                    c.strokeStyle = "#e8e8e8";
                                    c.beginPath();
                                    c.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * p);
                                    c.stroke();
                                }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.fmt(root.remaining)
                                color: root.fg
                                font.pixelSize: 48
                                font.family: "monospace"
                                font.weight: Font.Light
                                opacity: root.running ? 1 : 0.6
                                Behavior on opacity { NumberAnimation { duration: 200 } }
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.tag.trim() === "" ? "untagged" : root.tag
                                color: root.dim
                                font.pixelSize: 12
                                font.family: "monospace"
                            }
                        }
                    }

                    // presets + custom
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8
                        Repeater {
                            model: [5, 15, 25, 50]
                            Chip {
                                required property int modelData
                                label: modelData + "m"
                                active: root.minutes === modelData
                                onClicked: root.setMinutes(modelData)
                            }
                        }
                        Rectangle {
                            implicitWidth: 64
                            implicitHeight: 30
                            radius: 15
                            color: root.surface
                            border.color: minIn.activeFocus ? "#555555" : root.line
                            TextInput {
                                id: minIn
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                verticalAlignment: TextInput.AlignVCenter
                                horizontalAlignment: TextInput.AlignHCenter
                                color: root.fg
                                font.pixelSize: 12
                                font.family: "monospace"
                                validator: IntValidator { bottom: 1; top: 240 }
                                selectByMouse: true
                                onAccepted: { root.setMinutes(parseInt(text)); text = ""; card.forceActiveFocus(); }
                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    visible: !minIn.text.length
                                    text: "custom"
                                    color: "#555555"
                                    font.pixelSize: 11
                                    font.family: "monospace"
                                }
                            }
                        }
                    }

                    // tag input
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 36
                        radius: 8
                        color: root.surface
                        border.color: tagIn.activeFocus ? "#555555" : root.line
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                        TextInput {
                            id: tagIn
                            anchors.fill: parent
                            anchors.margins: 10
                            verticalAlignment: TextInput.AlignVCenter
                            color: root.fg
                            font.pixelSize: 13
                            font.family: "monospace"
                            clip: true
                            selectByMouse: true
                            onTextEdited: root.tag = text
                            onAccepted: card.forceActiveFocus()
                            Connections {
                                target: root
                                function onTagChanged() { if (tagIn.text !== root.tag) tagIn.text = root.tag; }
                            }
                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                visible: !tagIn.text.length
                                text: "tag (e.g. rust, dsa)"
                                color: "#555555"
                                font.pixelSize: 13
                                font.family: "monospace"
                            }
                        }
                    }

                    // recent tags
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: root.recent
                            Chip {
                                required property string modelData
                                label: modelData
                                active: root.tag === modelData
                                onClicked: root.tag = modelData
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }

                    Item { Layout.fillHeight: true }

                    // controls
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        Chip {
                            implicitWidth: 120
                            implicitHeight: 40
                            label: root.running ? "pause" : "start"
                            active: true
                            onClicked: root.running ? root.pause() : root.start()
                        }
                        Chip {
                            implicitWidth: 90
                            implicitHeight: 40
                            label: "reset"
                            onClicked: root.reset()
                        }
                    }
                }

                // ---------- history view ----------
                ColumnLayout {
                anchors.fill: parent
                spacing: 12
                visible: opacity > 0
                opacity: root.view === "history" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Text {
                    text: root.sessions.length >= 0 ? root.todayStats() : ""
                    color: root.dim
                    font.pixelSize: 12
                    font.family: "monospace"
                }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    model: root.sessions.slice().reverse()
                    delegate: Rectangle {
                        required property var modelData
                        width: list.width
                        height: 44
                        radius: 8
                        color: root.surface
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10
                            Text {
                                Layout.fillWidth: true
                                text: modelData.tag
                                elide: Text.ElideRight
                                color: root.fg
                                font.pixelSize: 13
                                font.family: "monospace"
                            }
                            Text {
                                text: modelData.minutes + "m"
                                color: "#b0b0b0"
                                font.pixelSize: 12
                                font.family: "monospace"
                            }
                            Text {
                                text: Qt.formatDateTime(new Date(modelData.startedAt), "dd MMM HH:mm")
                                color: root.dim
                                font.pixelSize: 11
                                font.family: "monospace"
                            }
                        }
                    }
                }
            }

                // ---------- stats view ----------
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12
                    visible: opacity > 0
                    opacity: root.view === "stats" ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Connections {
                        target: root
                        function onViewChanged() { if (root.view === "stats") growAnim.restart(); }
                    }

                    // summary cards
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Repeater {
                            model: [
                                { v: root.fmtMins(root.todayMinutes), l: "today" },
                                { v: root.fmtMins(root.weekMinutes), l: "7 days" },
                                { v: root.streak + "d", l: "streak" }
                            ]
                            Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 58
                                radius: 10
                                color: root.surface
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.v
                                        color: root.fg
                                        font.pixelSize: 16
                                        font.family: "monospace"
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.l
                                        color: root.dim
                                        font.pixelSize: 11
                                        font.family: "monospace"
                                    }
                                }
                            }
                        }
                    }

                    // 7-day bar chart
                    Canvas {
                        id: chart
                        Layout.fillWidth: true
                        implicitHeight: 140
                        property real grow: 1
                        onGrowChanged: requestPaint()
                        Connections {
                            target: root
                            function onWeekDataChanged() { chart.requestPaint(); }
                        }
                        NumberAnimation {
                            id: growAnim
                            target: chart
                            property: "grow"
                            from: 0
                            to: 1
                            duration: 450
                            easing.type: Easing.OutCubic
                        }
                        onPaint: {
                            var c = getContext("2d");
                            c.reset();
                            var data = root.weekData, n = data.length;
                            var maxM = 30;
                            for (var i = 0; i < n; i++) maxM = Math.max(maxM, data[i].minutes);
                            var slot = width / n, barW = slot * 0.5;
                            var top = 18, bottom = height - 20, usable = bottom - top;
                            c.font = "11px monospace";
                            c.textAlign = "center";
                            for (var j = 0; j < n; j++) {
                                var x = j * slot + (slot - barW) / 2;
                                var h = Math.max(2, (data[j].minutes / maxM) * usable * grow);
                                c.fillStyle = data[j].minutes === 0 ? "#2a2a2a" : (data[j].today ? "#e8e8e8" : "#555555");
                                c.fillRect(x, bottom - h, barW, h);
                                c.fillStyle = data[j].today ? "#e8e8e8" : "#6b6b6b";
                                c.fillText(data[j].label, j * slot + slot / 2, height - 5);
                                if (data[j].minutes > 0 && grow > 0.9) {
                                    c.fillStyle = "#b0b0b0";
                                    c.fillText(root.fmtShort(data[j].minutes), j * slot + slot / 2, bottom - h - 5);
                                }
                            }
                        }
                    }

                    Text {
                        text: "by tag · all time"
                        color: root.dim
                        font.pixelSize: 11
                        font.family: "monospace"
                    }

                    ListView {
                        id: tagList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: root.tagTotals

                        Text {
                            anchors.centerIn: parent
                            visible: root.sessions.length === 0
                            text: "no sessions yet"
                            color: "#555555"
                            font.pixelSize: 12
                            font.family: "monospace"
                        }

                        delegate: Item {
                            required property var modelData
                            width: tagList.width
                            height: 34

                            Text {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                text: modelData.tag
                                color: root.fg
                                font.pixelSize: 13
                                font.family: "monospace"
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                text: root.fmtMins(modelData.minutes) + "  ·  " + modelData.count
                                color: root.dim
                                font.pixelSize: 12
                                font.family: "monospace"
                            }
                            Rectangle {
                                id: track
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 3
                                radius: 1.5
                                color: "#2a2a2a"
                                Rectangle {
                                    height: parent.height
                                    radius: parent.radius
                                    color: "#e8e8e8"
                                    width: track.width * modelData.minutes / Math.max(1, root.tagTotals[0].minutes)
                                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                                }
                            }
                        }
                    }
                }
            }   // views Item
            }   // outer ColumnLayout
        }
    }
}

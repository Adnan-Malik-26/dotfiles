pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// ============================================================================
// Pomodoro
// Timer state machine + session log + stats. No UI.
//
// Files (unchanged paths, so existing history carries over):
//   ~/.local/share/pomodoro/sessions.json   completed sessions
//   ~/.local/share/pomodoro/active.json     the in-flight timer, so a config
//                                           reload / shell restart doesn't lose it
//
// Timekeeping uses an absolute end timestamp, not a decrementing counter, so
// it stays correct across suspend and reloads.
//
// Restore rules (active.json): still running -> resume; ended while the shell
// was down by <= overdueGraceSec -> log it as completed; ended longer ago ->
// drop it (the user wasn't there).
//
// DND: `dndActive` is true while a session runs. shell.qml feeds it to
// NotificationDaemon.autoDnd — this service knows nothing about notifications.
// ============================================================================

Singleton {
    id: root

    // ---- config ----
    property bool dndWhileRunning: true
    readonly property string dataDir: Quickshell.env("HOME") + "/.local/share/pomodoro"
    readonly property string chimePath:
        Quickshell.env("HOME") + "/.local/share/quickshell/pomodoro/ding.mp3"
    readonly property int overdueGraceSec: 300

    // ---- state ----
    property int minutes: 25
    readonly property int total: minutes * 60
    property int remaining: 25 * 60
    property string tag: ""
    property bool running: false
    property double endAt: 0
    property double startedAt: 0
    property var sessions: []

    readonly property bool dndActive: running && dndWhileRunning

    property bool _sessionsReady: false
    property bool _activeRead: false
    property bool _ready: false
    property var _activeRaw: null

    // ---- controls ----
    function setMinutes(m) {
        if (running || !(m > 0)) return
        minutes = m
        remaining = total
    }

    function start() {
        if (remaining <= 0) remaining = total
        endAt = Date.now() + remaining * 1000
        if (startedAt === 0) startedAt = Date.now()
        running = true
    }

    function pause() {
        remaining = Math.max(0, Math.ceil((endAt - Date.now()) / 1000))
        running = false
    }

    function toggle() { running ? pause() : start() }

    function reset() {
        running = false
        startedAt = 0
        remaining = total
    }

    function finish(endedAt) {
        running = false   // first: lifts DND before the "done" toast is sent
        const entry = {
            tag: tag.trim() === "" ? "untagged" : tag.trim(),
            minutes: minutes,
            startedAt: startedAt,
            endedAt: endedAt || Date.now()
        }
        sessions = sessions.concat([entry])
        sessionsFile.setText(JSON.stringify(sessions, null, 1))
        Quickshell.execDetached(["notify-send", "-a", "pomodoro", "Session done", entry.tag + " · " + minutes + "m"])
        Quickshell.execDetached([
            "sh", "-c",
            'f="$1"; [ -f "$f" ] || exit 0; mpv --no-video --really-quiet "$f" || ffplay -nodisp -autoexit -loglevel quiet "$f"',
            "sh", chimePath
        ])
        startedAt = 0
        remaining = total
    }

    Timer {
        interval: 250
        repeat: true
        running: root.running
        onTriggered: {
            root.remaining = Math.max(0, Math.ceil((root.endAt - Date.now()) / 1000))
            if (root.remaining <= 0) root.finish()
        }
    }

    // ---- formatting ----
    function fmtClock(s) {
        const m = Math.floor(s / 60), r = s % 60
        return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r
    }
    function fmtMins(m) { return m < 60 ? m + "m" : Math.floor(m / 60) + "h " + (m % 60) + "m" }
    function fmtShort(m) { return m < 60 ? m + "m" : (m / 60).toFixed(1) + "h" }
    function dayKey(d) { return d.getFullYear() + "-" + d.getMonth() + "-" + d.getDate() }

    // ---- stats (all derived from `sessions`) ----
    readonly property var recent: {
        const seen = []
        for (let i = sessions.length - 1; i >= 0 && seen.length < 5; i--) {
            const t = sessions[i].tag
            if (seen.indexOf(t) < 0) seen.push(t)
        }
        return seen
    }

    readonly property string todaySummary: {
        const day = new Date().toDateString()
        let mins = 0, n = 0
        for (const s of sessions) {
            if (new Date(s.startedAt).toDateString() === day) { mins += s.minutes; n++ }
        }
        return n + " sessions · " + Math.floor(mins / 60) + "h " + (mins % 60) + "m today"
    }

    // last 7 days, oldest -> today
    readonly property var weekData: {
        const byDay = {}, out = [], names = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        for (const s of sessions) {
            const k = dayKey(new Date(s.startedAt))
            byDay[k] = (byDay[k] || 0) + s.minutes
        }
        const now = new Date()
        for (let j = 6; j >= 0; j--) {
            const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - j)
            out.push({ label: names[d.getDay()], minutes: byDay[dayKey(d)] || 0, today: j === 0 })
        }
        return out
    }

    readonly property int todayMinutes: weekData[6].minutes
    readonly property int weekMinutes: {
        let t = 0
        for (const d of weekData) t += d.minutes
        return t
    }

    // consecutive days with >= 1 session; stays alive until the end of today
    readonly property int streak: {
        const days = {}
        for (const s of sessions) days[dayKey(new Date(s.startedAt))] = true
        const n = new Date()
        let d = new Date(n.getFullYear(), n.getMonth(), n.getDate())
        if (!days[dayKey(d)]) d = new Date(d.getFullYear(), d.getMonth(), d.getDate() - 1)
        let count = 0
        while (days[dayKey(d)]) {
            count++
            d = new Date(d.getFullYear(), d.getMonth(), d.getDate() - 1)
        }
        return count
    }

    // all-time per-tag totals, biggest first
    readonly property var tagTotals: {
        const m = {}, arr = []
        for (const s of sessions) {
            if (!m[s.tag]) m[s.tag] = { tag: s.tag, minutes: 0, count: 0 }
            m[s.tag].minutes += s.minutes
            m[s.tag].count++
        }
        for (const k in m) arr.push(m[k])
        arr.sort((a, b) => b.minutes - a.minutes)
        return arr
    }

    // minutes focused per hour of day (index 0-23), all time. A session is
    // spread over the hours it actually spans: 50 min starting 10:40 counts as
    // 20 min in hour 10 and 30 min in hour 11.
    readonly property var hourData: {
        const h = new Array(24).fill(0)
        for (const s of sessions) {
            let t = s.startedAt, left = s.minutes * 60000
            if (!(t > 0) || !(left > 0)) continue
            while (left > 0) {
                const d = new Date(t)
                const next = new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours() + 1).getTime()
                const chunk = Math.min(left, next - t)
                if (!(chunk > 0)) break
                h[d.getHours()] += chunk / 60000
                t += chunk
                left -= chunk
            }
        }
        return h
    }

    readonly property int peakHour: {
        let best = -1, bestV = 0
        for (let i = 0; i < 24; i++) if (hourData[i] > bestV) { bestV = hourData[i]; best = i }
        return best
    }

    function hourLabel(h) { return (h < 10 ? "0" : "") + h + ":00" }
    readonly property string peakLabel:
        peakHour < 0 ? "" : "peak " + hourLabel(peakHour) + "–" + hourLabel((peakHour + 1) % 24)

    // ---- persistence ----
    Process {
        command: ["mkdir", "-p", root.dataDir]
        running: true
    }

    FileView {
        id: sessionsFile
        path: root.dataDir + "/sessions.json"
        atomicWrites: true
        onLoaded: {
            try {
                const arr = JSON.parse(text())
                if (Array.isArray(arr)) root.sessions = arr
            } catch (e) {
                console.warn("Pomodoro: could not parse sessions.json:", e)
            }
            root._sessionsReady = true
            root._tryRestore()
        }
        onLoadFailed: { root._sessionsReady = true; root._tryRestore() }
    }

    FileView {
        id: activeFile
        path: root.dataDir + "/active.json"
        atomicWrites: true
        onLoaded: {
            try { root._activeRaw = JSON.parse(text()) } catch (e) { root._activeRaw = null }
            root._activeRead = true
            root._tryRestore()
        }
        onLoadFailed: { root._activeRead = true; root._tryRestore() }
    }

    function _tryRestore() {
        if (_ready || !_sessionsReady || !_activeRead) return
        const d = _activeRaw
        if (d) {
            if (d.minutes > 0) minutes = d.minutes
            tag = d.tag || ""
            startedAt = d.startedAt || 0
            remaining = d.remaining > 0 ? d.remaining : total
            if (d.running && d.endAt) {
                const late = Date.now() - d.endAt
                if (late < 0) {
                    endAt = d.endAt
                    remaining = Math.ceil(-late / 1000)
                    running = true
                } else if (late <= overdueGraceSec * 1000) {
                    finish(d.endAt)                 // finished while the shell was down
                } else {
                    startedAt = 0                   // stale: drop it
                    remaining = total
                }
            }
        }
        _ready = true
        _saveActive()
    }

    Timer { id: saveTimer; interval: 300; onTriggered: root._saveActive() }
    function _scheduleSave() { if (_ready) saveTimer.restart() }
    function _saveActive() {
        activeFile.setText(JSON.stringify({
            minutes: minutes, tag: tag, remaining: remaining,
            running: running, endAt: endAt, startedAt: startedAt
        }))
    }

    onRunningChanged: _scheduleSave()
    onMinutesChanged: _scheduleSave()
    onTagChanged: _scheduleSave()
    onStartedAtChanged: _scheduleSave()
    onRemainingChanged: { if (!running) _scheduleSave() }   // not per tick while running
}

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// ============================================================================
// NotificationDaemon
// The ONLY thing in this config that talks to org.freedesktop.Notifications.
// Everything else (center, popups, cards) reads from this singleton.
//
// Two views of the same data:
//   - `history` : every tracked notification, newest first (backs the center)
//   - `popups`  : subset currently shown as toasts, self-expiring per urgency
//
// `history` mixes two kinds of entries:
//   - live Notification objects (this session, from the DBus server)
//   - "revived" plain JS objects (loaded from disk, from a previous session)
// NotificationCard treats both identically — it only ever calls `.dismiss()`
// and reads display fields. Revived entries carry their own `dismiss()` that
// just removes them from history. Actions don't survive a restart (the
// sender's DBus connection is gone), so revived entries have `actions: []`.
//
// Do Not Disturb: `dnd` suppresses toasts only. Everything still lands in
// history, and Critical (urgency 2) notifications bypass it.
//
// Persistence: FileView.setText (no shell, no argv size limit), debounced so
// a burst of notifications costs one write, atomic so a crash can't leave a
// truncated file.
// ============================================================================

Singleton {
    id: root

    // ---- tuning (was config.js) ----
    readonly property int historyLimit: 50
    readonly property string statePath:
        Quickshell.env("HOME") + "/.local/state/quickshell/notifications.json"

    // NotificationUrgency: Low = 0, Normal = 1, Critical = 2
    function urgencyTimeout(urgency) {
        if (urgency === 2) return 0      // 0 = sticky, requires explicit dismiss
        if (urgency === 0) return 3000
        return 5000
    }

    // ---- state ----
    property var history: []
    property var popups: []
    property bool manualDnd: false   // toggled by hand (IPC)
    property bool autoDnd: false     // driven from shell.qml (e.g. pomodoro running)
    readonly property bool dnd: manualDnd || autoDnd
    property bool _loaded: false   // guards against persisting mid-load

    function clearAll() {
        const items = [...history]
        history = []
        for (const n of items) n.dismiss()
    }

    NotificationServer {
        id: server
        keepOnReload: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: false
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true
            root.history = [notification, ...root.history].slice(0, root.historyLimit)
            root._pushPopup(notification)

            // Real dismissal (× button, action invoke, clearAll) — not the
            // popup auto-timeout, which only hides the toast and leaves
            // the entry in history.
            notification.closed.connect(() => {
                root.history = root.history.filter(n => n !== notification)
                root._popPopup(notification)
            })
        }
    }

    function _pushPopup(notification) {
        if (root.dnd && notification.urgency !== 2) return   // history only

        popups = [...popups, notification]

        const ms = root.urgencyTimeout(notification.urgency)
        if (ms > 0) {
            const timer = Qt.createQmlObject(
                "import QtQuick; Timer { interval: " + ms + "; running: true; repeat: false }",
                root
            )
            timer.triggered.connect(() => {
                root._popPopup(notification)
                timer.destroy()
            })
        }
    }

    function _popPopup(notification) {
        popups = popups.filter(n => n !== notification)
    }

    // ---- persistence -------------------------------------------------

    Process {
        command: ["mkdir", "-p", root.statePath.substring(0, root.statePath.lastIndexOf("/"))]
        running: true
    }

    FileView {
        id: stateFile
        path: root.statePath
        atomicWrites: true

        onLoaded: {
            try {
                const arr = JSON.parse(text())
                const revived = arr.map(root._reviveEntry)
                // A live notification may have arrived before the load
                // finished — keep it on top rather than clobbering it.
                root.history = [...root.history, ...revived].slice(0, root.historyLimit)
            } catch (e) {
                console.warn("NotificationDaemon: failed to parse persisted history:", e)
            }
            root._loaded = true
        }
        onLoadFailed: root._loaded = true   // first run / no file yet
    }

    Timer {
        id: persistTimer
        interval: 300
        onTriggered: root._persist()
    }

    onHistoryChanged: {
        if (root._loaded) persistTimer.restart()
    }

    function _reviveEntry(raw) {
        return {
            appName: raw.appName || "",
            summary: raw.summary || "",
            body: raw.body || "",
            bodyMarkup: !!raw.bodyMarkup,
            image: raw.image || "",
            time: new Date(raw.time),
            urgency: raw.urgency,
            actions: [],
            dismiss: function () {
                root.history = root.history.filter(n => n !== this)
            }
        }
    }

    function _persist() {
        const snapshot = root.history.map(n => ({
            appName: n.appName || "",
            summary: n.summary || "",
            body: n.body || "",
            bodyMarkup: !!n.bodyMarkup,
            image: n.image || "",
            time: (n.time ? new Date(n.time) : new Date()).toISOString(),
            urgency: n.urgency
        }))
        stateFile.setText(JSON.stringify(snapshot))
    }
}

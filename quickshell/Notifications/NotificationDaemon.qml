pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "config.js" as Config

// ============================================================================
// NotificationDaemon
// The ONLY thing in this module that talks to org.freedesktop.Notifications.
// Everything else (center, popups, cards) reads from this singleton.
//
// Two views of the same data:
//   - `history` : every tracked notification, newest first (backs the center)
//   - `popups`  : subset currently shown as toasts, self-expiring per urgency
//
// `history` mixes two kinds of entries:
//   - live Notification objects (this session, from the DBus server)
//   - "revived" plain JS objects (loaded from disk, from a previous session)
// NotificationCard treats both identically — it only ever calls
// `.dismiss()` and reads display fields, never anything DBus-specific — so
// revived entries carry their own no-op-to-DBus `dismiss()` that just
// removes them from history. Actions don't survive a restart (the sender's
// DBus connection is gone), so revived entries always have `actions: []`.
// ============================================================================

Singleton {
    id: root

    property var history: []
    property var popups: []
    property bool _loaded: false   // guards against persisting mid-load

    function clearAll() {
        const items = [...history]
        history = []
        for (const n of items) n.dismiss()
    }

    Component.onCompleted: loadProc.running = true

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
            root.history = [notification, ...root.history].slice(0, Config.history.limit)
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
        popups = [...popups, notification]

        const ms = Config.urgencyTimeout(notification.urgency)
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

    onHistoryChanged: {
        if (root._loaded) root._persist()
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
        const json = JSON.stringify(snapshot)
        // base64 round-trip avoids any shell-quoting issues with quotes/
        // unicode in notification text; the alphabet is quote-safe so it's
        // fine to embed directly inside single quotes below.
        const b64 = Qt.btoa(unescape(encodeURIComponent(json)))
        persistProc.command = [
            "sh", "-c",
            "mkdir -p \"$(dirname " + Config.history.statePath + ")\" && " +
            "echo '" + b64 + "' | base64 -d > " + Config.history.statePath
        ]
        persistProc.running = true
    }

    Process {
        id: persistProc
    }

    Process {
        id: loadProc
        command: ["sh", "-c", "cat " + Config.history.statePath + " 2>/dev/null"]
        stdout: SplitParser {
            onRead: line => {
                if (line.trim() !== "") {
                    try {
                        const arr = JSON.parse(line)
                        root.history = arr.map(root._reviveEntry).slice(0, Config.history.limit)
                    } catch (e) {
                        console.warn("NotificationDaemon: failed to parse persisted history:", e)
                    }
                }
                root._loaded = true
            }
        }
        onExited: {
            // Empty file / no prior history at all — SplitParser never fired.
            if (!root._loaded) root._loaded = true
        }
    }
}


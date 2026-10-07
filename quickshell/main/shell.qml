import QtQml
import Quickshell
import Quickshell.Io
import "services"
import "modules/notifications"
import "modules/osd"
import "modules/network"
import "modules/pomodoro"
import "modules/hoverclock"
import "modules/menu"

// ============================================================================
// Root. The only ShellRoot in the config — it instantiates modules and holds
// the ONE place where services are wired together.
//
// Layering (keep it this way):
//   theme/       tokens only
//   components/  dumb reusable UI           (import theme)
//   services/    state + backends, no UI    (never import modules or each other)
//   modules/*    windows + views            (import theme, components, services)
// Modules never import each other.
// ============================================================================

ShellRoot {
    Notifications {}
    OSD {}
    Network {}
    PomodoroPanel {}
    HoverClock {}
    QuickMenu {}

    // qs -c main ipc call panels closeAll | current
    IpcHandler {
        target: "panels"
        function closeAll(): void { Panels.closeAll() }
        function current(): string { return Panels.current }
    }

    // Cross-service wiring. Toasts are held back while a pomodoro runs
    // (history still records; critical notifications bypass).
    // Turn off with `Pomodoro.dndWhileRunning: false` in services/Pomodoro.qml.
    Binding {
        target: NotificationDaemon
        property: "autoDnd"
        value: Pomodoro.dndActive
    }
}

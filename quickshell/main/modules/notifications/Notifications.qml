import Quickshell
import Quickshell.Io
import "../../services"

// ============================================================================
// Notifications — module root (a Scope, not a ShellRoot: shell.qml owns that)
//
// External control (bind these to Hyprland keybinds):
//   qs ipc call notifications toggle      # open/close the center
//   qs ipc call notifications clear       # clear all notifications
//   qs ipc call notifications toggleDnd   # do-not-disturb on/off (toasts only)
// Volume/brightness keys don't need IPC — call `wpctl`/`brightnessctl` from
// your Hyprland bindd as usual; Audio/Brightness singletons pick the change
// up on their own and the OSD fires automatically.
// ============================================================================

Scope {
    id: root

    NotificationCenter { id: center }

    // One popup window per queued toast. Quickshell's Variants re-syncs
    // instances against NotificationDaemon.popups as it changes.
    Variants {
        model: NotificationDaemon.popups
        NotificationPopup {
            required property var modelData
            notification: modelData
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void { center.toggle() }
        function clear(): void { NotificationDaemon.clearAll() }
        function toggleDnd(): void { NotificationDaemon.manualDnd = !NotificationDaemon.manualDnd }
    }
}

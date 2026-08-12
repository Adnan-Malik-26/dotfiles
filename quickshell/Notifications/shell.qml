import Quickshell
import Quickshell.Io
import "config.js" as Config

// ============================================================================
// Notifications — root
//
// Two ways to use this directory:
//   1. Standalone shell: rename this file to `shell.qml` and run
//        qs -c Notifications
//   2. Module inside an existing Quickshell config: import this directory
//      from your top-level shell.qml, e.g.
//        import "Notifications" as Notif
//        Notif.Notifications { }
//
// External control (bind these to Hyprland keybinds):
//   qs ipc call notifications toggle   # open/close the center
//   qs ipc call notifications clear    # clear all notifications
// Volume/brightness keys don't need IPC — just call `wpctl`/`brightnessctl`
// from your Hyprland bindd as usual; Audio/Brightness singletons pick the
// change up on their own and the OSD fires automatically.
// ============================================================================

ShellRoot {
    id: root

    NotificationCenter { id: center }
    OSD { id: osd }

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
    }
}

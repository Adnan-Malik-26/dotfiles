import Quickshell
import Quickshell.Io

// ============================================================================
// Pomodoro — module root. State lives in services/Pomodoro; this is just the
// window and its IPC.
//   qs -c main ipc call pomo toggle | show | hide
// ============================================================================

Scope {
    PomodoroWindow { id: win }

    IpcHandler {
        target: "pomo"
        function toggle(): void { win.shown = !win.shown }
        function show(): void { win.shown = true }
        function hide(): void { win.shown = false }
    }
}

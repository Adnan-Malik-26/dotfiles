import Quickshell
import Quickshell.Io
import "../../services"

// ============================================================================
// Pomodoro — module root. State lives in services/Pomodoro, open/closed state
// in services/Panels; this is just the window and its IPC.
//   qs -c main ipc call pomo toggle | show | hide
// ============================================================================

Scope {
    PomodoroWindow { id: win }

    IpcHandler {
        target: "pomo"
        function toggle(): void { Panels.toggle("pomodoro") }
        function show(): void { Panels.open("pomodoro") }
        function hide(): void { Panels.close("pomodoro") }
    }
}

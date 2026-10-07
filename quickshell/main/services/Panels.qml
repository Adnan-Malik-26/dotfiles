pragma Singleton

import QtQuick
import Quickshell

// ============================================================================
// Panels
// Which interactive overlay is open: "" or one of
//   notifications | wifi | bluetooth | pomodoro | menu | wallpaper
// Exactly one at a time — opening a panel replaces the current one, so panels
// never stack and nothing needs hardcoded offsets to avoid overlapping.
// Windows bind `visible` to `Panels.current === "<name>"` and react to
// visibility in onVisibleChanged (so replacement runs the same side effects as
// closing). close(name) only closes if that panel is the current one, so a
// stale "focus grab cleared" from a panel that was just replaced is a no-op.
// Toasts, OSD and the hover clock are not panels.
// ============================================================================

Singleton {
    property string current: ""

    function isOpen(name) { return current === name }
    function open(name) { current = name }
    function close(name) { if (current === name) current = "" }
    function toggle(name) { current = current === name ? "" : name }
    function closeAll() { current = "" }
}

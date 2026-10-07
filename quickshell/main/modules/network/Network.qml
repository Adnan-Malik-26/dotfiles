import Quickshell
import Quickshell.Io

// ============================================================================
// Network — module root (a Scope, not a ShellRoot: shell.qml owns that)
//
// External control (bind these to Hyprland keybinds):
//   qs ipc call network toggleWifi
//   qs ipc call network toggleBluetooth
// ============================================================================

Scope {
    id: root

    WifiPopup { id: wifi }
    BluetoothPopup { id: bluetooth }

    IpcHandler {
        target: "network"
        function toggleWifi(): void { wifi.toggle() }
        function toggleBluetooth(): void { bluetooth.toggle() }
    }
}

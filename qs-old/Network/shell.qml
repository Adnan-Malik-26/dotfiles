import Quickshell
import Quickshell.Io
import "config.js" as Config

// ============================================================================
// Network — root
//
// Two ways to use this directory:
//   1. Standalone shell: run `qs -c Network`
//   2. Module inside an existing Quickshell config:
//        import "Network" as Net
//        Net.Network { }
//
// External control (bind these to Hyprland keybinds):
//   qs ipc call network toggleWifi
//   qs ipc call network toggleBluetooth
// ============================================================================

ShellRoot {
    id: root

    WifiPopup { id: wifi }
    BluetoothPopup { id: bluetooth }

    IpcHandler {
        target: "network"
        function toggleWifi(): void { wifi.toggle() }
        function toggleBluetooth(): void { bluetooth.toggle() }
    }
}

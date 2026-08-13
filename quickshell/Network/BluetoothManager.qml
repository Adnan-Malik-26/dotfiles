pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "config.js" as Config

// ============================================================================
// BluetoothManager
// Thin convenience wrapper around Quickshell.Bluetooth (talks to BlueZ over
// DBus natively — no subprocess, no polling, no string parsing). Unlike
// WifiManager this isn't a shell-out shim: BluetoothAdapter/BluetoothDevice
// are live DBus-object-manager-backed QML objects, so BluetoothPopup could
// bind to `Bluetooth.defaultAdapter.devices` directly. This wrapper exists
// only to centralize the "no adapter present" null-guard and the
// scan-with-auto-timeout behavior, so every call site doesn't repeat it.
// ============================================================================

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool discovering: available && adapter.discovering
    readonly property var devices: available ? adapter.devices : Bluetooth.devices

    function toggleAdapter() {
        if (!available) return
        adapter.enabled = !adapter.enabled
    }

    function startDiscovery() {
        if (!available || !adapter.enabled) return
        adapter.discovering = true
        discoveryTimer.restart()
    }

    function stopDiscovery() {
        if (!available) return
        adapter.discovering = false
        discoveryTimer.stop()
    }

    function connectDevice(device) { device.connect() }
    function disconnectDevice(device) { device.disconnect() }
    function pairDevice(device) { device.pair() }
    function forgetDevice(device) { device.forget() }

    // BlueZ scans keep running until told to stop — auto-stop after a
    // burst so the adapter isn't left discovering (and burning power)
    // just because someone closed the popup without hitting "Stop".
    Timer {
        id: discoveryTimer
        interval: Config.timeout.scanBurst
        repeat: false
        onTriggered: root.stopDiscovery()
    }
}

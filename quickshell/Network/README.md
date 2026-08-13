# Quickshell Network Popup (WiFi + Bluetooth)

## Layout
```
Network/
├── config.js            # theme / font / timeout / layout — edit this, nothing else
├── shell.qml             # root: wires managers, popups, IPC
├── WifiManager.qml        # singleton — nmcli-backed WiFi state (scan/connect/forget)
├── BluetoothManager.qml   # singleton — native Quickshell.Bluetooth (BlueZ/DBus) wrapper
├── WifiPopup.qml          # panel: radio toggle + scan + network list
├── BluetoothPopup.qml     # panel: adapter toggle + discovery + device list
├── NetworkItem.qml        # single WiFi network row (+ inline password entry)
└── DeviceItem.qml         # single Bluetooth device row
```

## Dependencies
- `quickshell` built with the Bluetooth module enabled (`Quickshell.Bluetooth` —
  ships with quickshell itself, not a separate service module).
- `NetworkManager` + `nmcli` on PATH for WiFi. `bluez` + `bluetoothd` running
  for Bluetooth (DBus service `org.bluez`).
- Same icon-font assumption as the Notifications module: signal/lock/
  bluetooth glyphs are raw Nerd Font codepoints, not resolved via
  `Quickshell.iconPath()`. If your font doesn't ship these glyphs you'll
  see tofu boxes — swap in an icon-theme lookup if that matters to you.

## Wiring it up (Hyprland)
```
exec-once = qs -c Network

bindd = SUPER, W, Toggle WiFi panel, exec, qs ipc call network toggleWifi
bindd = SUPER, B, Toggle Bluetooth panel, exec, qs ipc call network toggleBluetooth
```

## Architecture decision worth understanding: why two different backends
- **Bluetooth → native `Quickshell.Bluetooth`.** This is a first-class
  Quickshell module talking to BlueZ over DBus directly — no subprocess, no
  polling, no text parsing. `BluetoothDevice` objects are live and update
  their own properties (`connected`, `battery`, `pairing`, ...) as BlueZ
  emits DBus signals. `BluetoothManager.qml` is a thin convenience wrapper,
  not a shim.
- **WiFi → `nmcli` subprocess, same pattern as `Brightness.qml`.**
  Quickshell does ship a `Quickshell.Networking` module (NetworkManager over
  DBus), but its WiFi/AccessPoint API surface wasn't stable/documented
  enough at time of writing to build against without guessing property
  names — and guessing wrong in a DBus binding fails silently or crashes at
  runtime, not at compile time. `nmcli` is slower (poll-based, text
  parsing) and uglier, but it's a contract that doesn't change under you.
  **This is the one thing in this module you should revisit**: once you've
  confirmed `Quickshell.Networking`'s actual API against your installed
  Quickshell version, replacing `WifiManager.qml`'s internals with native
  DBus calls removes the polling entirely — nothing outside that file
  needs to change. That refactor (subprocess-parsing service → native
  DBus service, same public interface) is itself a good "system design
  trade-offs" story for an interview.

## Known trade-offs (read before you ship this)
1. **`forgetNetwork(ssid)` assumes the saved connection profile is named
   after its SSID** (nmcli's default when you `device wifi connect`). If
   you've renamed a profile, or two different networks share an SSID and
   both got auto-generated profiles, this can delete the wrong one. Fix:
   resolve by connection UUID via `nmcli -t -f NAME,UUID connection show`
   instead of by name.
2. **`nmcli`'s terse-output colon-escaping is hand-parsed** in
   `WifiManager.splitTerseLine()`. It handles the common case (`\:` and
   `\\` inside a field) but hasn't been fuzzed against pathological SSIDs.
   If you see a network with an unusual name (emoji, unpaired backslash)
   render wrong, that's why.
3. **WiFi list refreshes on a 10s timer** (`Config.timeout.scanInterval`)
   while the radio is on, same cost profile as `Brightness.qml`'s 2s poll
   but coarser since a WiFi scan is a heavier syscall than a sysfs read.
   Tighten it if you want fresher signal-strength numbers; widen it if
   you're running on battery and care about the wakeups.
4. **No click-outside-to-close portability** — same `HyprlandFocusGrab`
   coupling as `NotificationCenter.qml`. Swap for a fullscreen transparent
   input-catcher if you go compositor-agnostic.
5. **Password entry is a plain `TextField`**, not stored anywhere by this
   module — nmcli itself persists the PSK into the connection profile
   (root-readable, standard NetworkManager behavior). No additional
   secret-handling was added here; don't assume this module hides the
   password from anything nmcli wouldn't already expose.

## Next steps worth doing before you call this resume-worthy
- Replace `WifiManager`'s nmcli backend with native `Quickshell.Networking`
  DBus calls (see above) — this is the single highest-signal change here:
  it's the difference between "shells out and parses text" and "properly
  integrated with the system service," and it's a concrete before/after
  you can describe in an interview.
- Add connection-quality signal (RSSI history, not just current bars) if
  you want this to do more than mirror what `nmcli` already tells you.
- Surface saved-but-out-of-range networks (from `nmcli connection show`)
  as a separate "Saved" section so forgetting a network doesn't require it
  to currently be in scan range.

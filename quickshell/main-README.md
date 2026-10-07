# Quickshell config — main

```
shell.qml                     only ShellRoot; instantiates modules + the one service-wiring Binding
theme/Theme.qml               colors / font / radii / motion (single source of truth)
components/Chip.qml           dumb reusable UI
services/                     state + backends, no UI
  Audio Brightness CapsLock WifiManager BluetoothManager NotificationDaemon
  Pomodoro Clock Clipboard Frecency
modules/
  notifications/  osd/  network/
  pomodoro/       PomodoroPanel (+ Window, Timer/History/Stats views)
  hoverclock/     HoverClock (clock + calendar, shows pomodoro countdown)
  menu/           QuickMenu (+ Window): apps / clipboard / power
```
Rules: modules import theme + components + services, never each other. Services
never import modules and never each other — cross-service wiring lives in
shell.qml only.

## Install
```
cp -r main ~/.config/quickshell/main
qs -c main
```
Stop the old `qs -c Notifications|Network|pomodoro|hoverclock|menu` instances first.
Running as `-c main` means every IPC call needs `-c main` (or rename the dir to `default`).

## Hyprland
```
exec-once = qs -c main
exec-once = wl-paste --type text  --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

bindd = SUPER, N,         Notification center, exec, qs -c main ipc call notifications toggle
bindd = SUPER, W,         WiFi panel,          exec, qs -c main ipc call network toggleWifi
bindd = SUPER, B,         Bluetooth panel,     exec, qs -c main ipc call network toggleBluetooth
bindd = SUPER, P,         Pomodoro,            exec, qs -c main ipc call pomo toggle
bindd = SUPER, SPACE,     App launcher,        exec, qs -c main ipc call menu toggle apps
bindd = SUPER, V,         Clipboard,           exec, qs -c main ipc call menu toggle clipboard
bindd = SUPER SHIFT, E,   Power menu,          exec, qs -c main ipc call menu toggle power
bindd = SUPER SHIFT, N,   Do not disturb,      exec, qs -c main ipc call notifications toggleDnd
```
`qs -c main ipc show` lists every registered target.

## Behaviour worth knowing
- **Pomodoro survives reloads.** The running timer is saved to
  ~/.local/share/pomodoro/active.json. On start: still running -> resumes; ended
  while the shell was down by <= 5 min -> logged as completed; older -> dropped.
  Sessions still go to ~/.local/share/pomodoro/sessions.json (old history carries over).
- **Auto-DND.** While a session runs, toasts are suppressed (history still
  records, critical notifications bypass). Disable: `property bool dndWhileRunning: false`
  in services/Pomodoro.qml. Manual DND (`toggleDnd`) is independent.
- **Hoverclock** shows `hh:mm · mm:ss` while a pomodoro runs; click it for the calendar.
- **Pomodoro window starts hidden** (it used to open at launch). Toggle with the bind.
- Chime: ~/.local/share/quickshell/pomodoro/ding.mp3 (needs mpv or ffplay).
- App ranking uses frecency (~/.local/share/quickshell/menu/frecency.json).
- Palette: the three modules written outside the notification stack used a
  slightly different gray set (#0e0e0e bg etc.); they now use Theme, so they match
  the notification center (pure black bg, #3a3a3a borders). Change Theme.qml to restyle all.

## Verify
1. No "type not found" errors on `qs -c main` (fallback: `import qs.theme` style imports).
2. `qs -c main ipc show` lists notifications, network, pomo, menu.
3. Pomodoro: start, then edit any file in the config (forces a reload) — the timer must keep running.
4. Start a session, `notify-send hi` -> no toast, entry in center; `notify-send -u critical x` -> shows.
5. Menu: apps launch, clipboard copies, power asks twice for logout/reboot/shutdown.

## Still open
- CapsLock forks `cat` every 300 ms; Brightness forks `brightnessctl` every 2 s.
- Toasts: one layer-shell surface each.
- No panel manager (opening one popup doesn't close the others).
- Frecency/clipboard/pomodoro have no decay/size limits beyond cliphist's own.

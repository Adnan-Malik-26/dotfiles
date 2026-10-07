# Quickshell config — main

```
shell.qml                     only ShellRoot; instantiates modules + the one service-wiring Binding
systemd/quickshell.service    user unit (auto-restart)
scripts/deploy.sh             commit-gated restart with automatic rollback
theme/Theme.qml               colors / font / radii / motion (single source of truth)
components/Chip.qml           dumb reusable UI
services/                     state + backends, no UI
  Audio Brightness CapsLock WifiManager BluetoothManager NotificationDaemon
  Pomodoro Clock Clipboard Frecency Panels Wallpapers
modules/
  notifications/  osd/  network/
  pomodoro/       PomodoroPanel (+ Window, Timer/History/Stats views)
  hoverclock/     HoverClock (clock + calendar, shows pomodoro countdown)
  menu/           QuickMenu (+ Window): apps / clipboard / power
  wallpaper/      WallpaperPicker (+ Window): thumbnail grid for ~/walls/current, set via awww
```
Rules: modules import theme + components + services, never each other. Services
never import modules and never each other — cross-service wiring lives in
shell.qml only.

## Install / operate
```
cp -r main ~/.config/quickshell/main
cd ~/.config/quickshell/main && git init -b main && git add -A && git commit -m "initial"

mkdir -p ~/.config/systemd/user
cp systemd/quickshell.service ~/.config/systemd/user/
systemctl --user daemon-reload
scripts/deploy.sh                 # first run: starts it and tags the commit `last-good`
```
Stop any old `qs` instances first. Replace every `exec-once = qs ...` line in
hyprland.conf with the single line below (it imports the session environment the
service needs, then starts it):
```
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && systemctl --user start quickshell.service
```
(With uwsm, `systemctl --user enable quickshell.service` is enough.)

- Logs: `journalctl --user -u quickshell -f`
- Edit loop: save files (hot reload) -> when happy, `git commit` -> `scripts/deploy.sh`.
  A startup failure rolls back to `last-good` (detached HEAD, your branch untouched);
  `git switch main`, fix, commit, deploy again. Runtime QML errors don't kill the
  process, so deploy.sh can't catch those — watch the journal.
- Crash recovery works because state is on disk: pomodoro resumes from active.json,
  notification history reloads, the unit restarts after 2 s (max 5 tries / 60 s).
- Running as `-c main` means IPC calls need `-c main` (or rename the dir to `default`).

## Hyprland
```
exec-once = qs -c main
exec-once = awww-daemon
exec-once = wl-paste --type text  --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

bindd = SUPER, N,         Notification center, exec, qs -c main ipc call notifications toggle
bindd = SUPER, W,         WiFi panel,          exec, qs -c main ipc call network toggleWifi
bindd = SUPER, B,         Bluetooth panel,     exec, qs -c main ipc call network toggleBluetooth
bindd = SUPER, P,         Pomodoro,            exec, qs -c main ipc call pomo toggle
bindd = SUPER, SPACE,     App launcher,        exec, qs -c main ipc call menu toggle apps
bindd = SUPER, V,         Clipboard,           exec, qs -c main ipc call menu toggle clipboard
bindd = SUPER SHIFT, E,   Power menu,          exec, qs -c main ipc call menu toggle power
bindd = SUPER SHIFT, W,   Wallpaper picker,    exec, qs -c main ipc call wallpaper toggle
bindd = SUPER CTRL, W,    Random wallpaper,    exec, qs -c main ipc call wallpaper random
bindd = SUPER SHIFT, N,   Do not disturb,      exec, qs -c main ipc call notifications toggleDnd
```
`qs -c main ipc show` lists every registered target. `ipc call panels closeAll` closes whatever is open.

## Behaviour worth knowing
- **Pomodoro survives reloads.** The running timer is saved to
  ~/.local/share/pomodoro/active.json. On start: still running -> resumes; ended
  while the shell was down by <= 5 min -> logged as completed; older -> dropped.
  Sessions still go to ~/.local/share/pomodoro/sessions.json (old history carries over).
- **Auto-DND.** While a session runs, toasts are suppressed (history still
  records, critical notifications bypass). Disable: `property bool dndWhileRunning: false`
  in services/Pomodoro.qml. Manual DND (`toggleDnd`) is independent.
- **Hoverclock** shows `hh:mm · mm:ss` while a pomodoro runs; click it for the calendar.
- **One panel at a time.** Notification center, WiFi, Bluetooth, pomodoro and the menu are
  mutually exclusive (services/Panels). Opening one replaces the current one, so the old
  hardcoded Bluetooth margin is gone. Toasts, OSD and the hover clock are not panels.
- **Wallpapers.** Images (png jpg jpeg webp gif bmp svg) in ~/walls/current (a symlink is fine).
  Picker keys: arrows/hjkl move, Enter or click sets it and closes, R random (stays open), Esc closes.
  IPC: `wallpaper toggle | random | next | prev`. The in-use wallpaper has a dot badge.
  awww forgets its image when the daemon restarts, so the last choice is saved to
  ~/.local/state/quickshell/wallpaper and re-applied once at startup — but only if the
  daemon isn't already showing an image (set `restoreOnStart: false` in services/Wallpapers.qml
  if you restore it some other way). Failures raise a critical notification.
  Thumbnails are decoded by Qt at ~2x display size on demand (no cache on disk).
  Transition/fps: `transition` and `transitionFps` in services/Wallpapers.qml.
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
- Wallpapers: awww loses the image when a monitor is re-plugged; hook Hyprland's monitoradded event to re-apply.
- Toasts: one layer-shell surface each (one overlay window + ColumnLayout is the fix).
- CapsLock still re-reads its LED file every 300 ms (in-process now, no fork) and Brightness
  every 2 s; both could be event-driven (Hyprland bind -> IPC) at the cost of wiring.
- Pomodoro/clipboard/frecency have no size limits beyond cliphist's own.

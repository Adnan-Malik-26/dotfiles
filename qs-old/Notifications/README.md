# Quickshell Notification Center

## Layout
```
Notifications/
├── config.js              # theme / font / timeout — edit this, nothing else
├── Notifications.qml      # root: wires daemon, center, popups, OSD, IPC
├── NotificationDaemon.qml # singleton — owns the DBus NotificationServer
├── Audio.qml               # singleton — PipeWire default-sink volume/mute
├── Brightness.qml          # singleton — brightnessctl-backed backlight
├── CapsLock.qml             # singleton — sysfs LED watcher
├── NotificationCenter.qml  # panel: history list + media + sliders + clear-all
├── NotificationCard.qml    # single notification row (used in center + popup)
├── NotificationPopup.qml   # transient toast (one PanelWindow per active toast)
├── MediaControls.qml       # MPRIS widget
├── VolumeSlider.qml
├── BrightnessSlider.qml
└── OSD.qml                 # bottom OSD for volume / brightness / caps lock
```

## Dependencies
- `quickshell` (git.outfoxxed.me/quickshell) built with the Pipewire and
  Mpris service modules enabled.
- `brightnessctl` on PATH, with permission to write brightness (udev rule or
  `video` group membership — no permission, no set, only reads will work).
- `qt6-5compat` package — needed for `Qt5Compat.GraphicalEffects.ColorOverlay`,
  used by `Icon.qml` to recolor icon-theme SVGs.
- An installed icon theme with freedesktop symbolic icon names (Papirus,
  Adwaita, Breeze all ship these) — `Icon.qml` resolves names like
  `audio-volume-high-symbolic` via `Quickshell.iconPath()`. If your theme is
  missing a name, the icon renders blank; check `fallback` values in each
  call site or swap in whatever your theme actually ships.

## Wiring it up (Hyprland)
```
exec-once = qs -c Notifications

bindd = , XF86AudioRaiseVolume, Raise volume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindd = , XF86AudioLowerVolume, Lower volume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindd = , XF86MonBrightnessUp, Raise brightness, exec, brightnessctl set 5%+
bindd = , XF86MonBrightnessDown, Lower brightness, exec, brightnessctl set 5%-
bindd = SUPER, N, Toggle notification center, exec, qs ipc call notifications toggle
```
You don't route volume/brightness keys through Quickshell at all — `wpctl`/
`brightnessctl` mutate the real backend, and `Audio`/`Brightness` singletons
pick the change up via PipeWire's object tracker / polling respectively.
The OSD reacts on its own.

## Known trade-offs (read before you ship this)
1. **Popup stacking is index-based margin math**, not a real layout. Fine
   for a handful of short-lived toasts; if you push high notification
   volume (e.g. chat client with burst notifications), replace
   `NotificationPopup` with a single overlay `PanelWindow` containing a
   `ColumnLayout` of cards instead of one Wayland surface per toast — fewer
   layer-shell surfaces, cheaper compositor-side, and no manual offset math.
2. **Brightness polls every 2s** rather than reacting to hardware-key
   presses instantly through IPC. Acceptable latency for a slider/OSD; if
   you want zero-latency sync, have your Hyprland bind call
   `qs ipc call notifications brightnessChanged` after `brightnessctl set`
   instead of relying on the poll.
3. **No click-outside-to-close** on the notification center panel — noted
   inline in `NotificationCenter.qml`. Cleanest fix is a `HyprlandFocusGrab`
   from Quickshell's Hyprland module if you're willing to hard-couple to
   Hyprland; otherwise a full-screen transparent input-catcher window behind
   the panel works compositor-agnostically.
4. **CapsLock LED path discovery assumes exactly one `*capslock*` LED.**
   On multi-keyboard setups you may get the wrong device; pin `ledPath`
   manually in `CapsLock.qml` if `find` picks the wrong one.

## Next steps worth doing before you call this resume-worthy
- Swap the unicode glyph icons for a proper SVG/icon-font pipeline.
- Add a `NotificationGroup` layer (group by `appName`) once volume grows —
  this is the same pattern macOS/GNOME notification centers use and is a
  natural "system design" talking point in an interview.
- Persist history across Quickshell reloads (`trackedNotifications` resets
  otherwise) by serializing to a JSON file on change and replaying on
  `Component.onCompleted` — a good excuse to practice a small local
  read-through cache.

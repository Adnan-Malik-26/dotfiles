---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- ============================================================
-- Cursor Zoom Helper
-- ============================================================
-- Clamped 1.0-3.0x zoom, stepped via repeat-hold binds below.
-- hl.get_config("cursor.zoom_factor") returns the current scalar
-- value directly (dot-notation path, confirmed working).
local function zoom(delta)
	local current = hl.get_config("cursor.zoom_factor")
	local next_val = math.min(3.0, math.max(1.0, current + delta))
	hl.config({ cursor = { zoom_factor = next_val } })
end

-- ============================================================
-- App Launchers
-- ============================================================
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty -1"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("/home/adnanmalik/dotfiles/rofi/launchers/type-1/launcher.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("rofi-books.sh"))

-- ============================================================
-- Session & System Utilities
-- ============================================================
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock")) -- lock screen
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("hyprpicker -a")) -- color picker, autocopy to clipboard
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("$HOME/.local/bin/wallpaperSwitcher")) -- cycles wallpaper via awww
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("$HOME/.config/rofi/scripts/powermenu_t5")) -- rofi power menu
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("$HOME/.local/bin/waybar-switcher")) -- swaps waybar config/style
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("$HOME/.local/bin/switch-layout")) -- keyboard layout switcher
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("$HOME/.local/bin/chth")) -- custom script (chth)
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("qs -c Notifications ipc call notifications toggle")) -- toggle notification panel
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("notify-send 'Notifications Cleared' && qs -c Notifications ipc call notifications clear")) -- clear all notifications
hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("qs -c Network ipc call network toggleWifi")) -- toggle wifi
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("qs -c Network ipc call network toggleBluetooth")) -- toggle bluetooth

-- Clipboard history (backed by `wl-paste --watch cliphist store` in autostart)
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(
	"cliphist list | rofi -dmenu -p 'clipboard' -theme $HOME/dotfiles/rofi/minimal.rasi | cliphist decode | wl-copy"
), { description = "Clipboard history" })

-- Screen OCR: region-capture as raw PNG bytes over stdin -> tesseract -> clipboard
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd(
	"hyprshot -m region --raw | tesseract - - | wl-copy"
), { description = "OCR selected region >> clipboard" })

-- Cursor zoom (repeat-hold to ramp in/out)
hl.bind(mainMod .. " + Minus", function() zoom(-0.3) end, { repeating = true })
hl.bind(mainMod .. " + Equal", function() zoom(0.3) end, { repeating = true })

-- ============================================================
-- Window Management — Close / Float / Fullscreen / Pin
-- ============================================================
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- Scrolling has no true fullscreen concept (infinite tape) — "fit active"
-- resizes the column to fill the visible viewport instead.
hl.bind(mainMod .. " + F", hl.dsp.layout("fit active"))

-- Flat pin, not layout-aware (intentional — see conversation history if
-- you're wondering why this isn't a scratchpad/promote toggle).
hl.bind(mainMod .. " + P", hl.dsp.window.pin())

-- Cycle tiled <-> floating windows (jq check needed since Hyprland has no native "cycle only floating/tiled")
hl.bind("ALT + Space", hl.dsp.exec_cmd(
	'[ "$(hyprctl activewindow -j | jq -r ".floating")" = "true" ] && hyprctl dispatch cyclenext tiled || hyprctl dispatch cyclenext floating'
))

-- ============================================================
-- Focus Mode
-- ============================================================
-- SUPER+M: promote active window to a wide "focus" column (85% width),
-- then snap the viewport to it.
hl.bind(mainMod .. " + M", function()
	hl.dispatch(hl.dsp.layout("promote"))
	hl.dispatch(hl.dsp.layout("colresize 0.85"))
	hl.dispatch(hl.dsp.layout("fit active"))
end)
-- SUPER+SHIFT+M: reset column back to 50% width
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.layout("colresize 0.5"))

-- ============================================================
-- Window Focus Navigation (vim-style HJKL)
-- ============================================================
-- H/L move focus left/right along the scrolling tape (columns).
-- J/K move focus up/down within a column (vertical stacking, if any) —
-- this is layout-agnostic focus, not scrolling-specific.
hl.bind(mainMod .. " + H", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + L", hl.dsp.layout("focus r"))

-- Monitor focus (multi-monitor — currently dead on this single-monitor
-- laptop config, kept for when an external display is docked)
hl.bind(mainMod .. " + CTRL + comma", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + period", hl.dsp.focus({ monitor = "r" }))

-- ============================================================
-- Move Windows (HJKL + monitor)
-- ============================================================
-- H/L swap the active window's column with its left/right neighbor.
-- J/K move vertically within a column — layout-agnostic.
hl.bind(mainMod .. " + CTRL + H", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.layout("swapcol r"))

-- Move window to another monitor (same dead-until-docked note as above)
hl.bind(mainMod .. " + CTRL + SHIFT + comma", hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + SHIFT + period", hl.dsp.window.move({ monitor = "r" }))

-- ============================================================
-- Resize Windows (HJKL)
-- ============================================================
-- H/L resize the active column's width (scrolling-native colresize).
-- J/K resize height directly via hyprctl since scrolling has no
-- vertical-resize concept of its own.
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.layout("colresize -0.1"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 30"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -30"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.layout("colresize +0.1"))

-- ============================================================
-- Workspace Switching (1-0)
-- ============================================================
for i = 1, 10 do
	local key = i % 10 -- 10 maps to physical "0" key

	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- ============================================================
-- Mouse Bindings
-- ============================================================
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ============================================================
-- Screenshots (hyprshot) — Print and Insert both bound for keyboards without Print
-- ============================================================
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m window -o $HOME/Documents/Pictures/Screenshots/"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region -o ~/Documents/Pictures/Screenshots/"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m output -o ~/Documents/Pictures/Screenshots/"))

hl.bind("Insert", hl.dsp.exec_cmd("hyprshot -m window -o ~/Documents/Pictures/Screenshots/"))
hl.bind("SHIFT + Insert", hl.dsp.exec_cmd("hyprshot -m region -o ~/Documents/Pictures/Screenshots/"))
hl.bind(mainMod .. " + Insert", hl.dsp.exec_cmd("hyprshot -m output -o ~/Documents/Pictures/Screenshots/"))

-- ============================================================
-- Media & Hardware Keys
-- ============================================================
-- XF86 keys and F-row duplicates both bound so either keyboard
-- firmware mode (media-key-first or Fn-first) works out of the box.
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true })

hl.bind("F6", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true })
hl.bind("F8", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true })
hl.bind("F7", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true })

hl.bind("F3", hl.dsp.exec_cmd("brightnessctl set 5%+"),
	{ locked = true, repeating = true })
hl.bind("F2", hl.dsp.exec_cmd("brightnessctl set 5%-"),
	{ locked = true, repeating = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- ============================================================
-- Plugins / Pyprland Toggles
-- ============================================================
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("pypr toggle bluetuith")) -- bluetuith scratchpad terminal

-- ============================================================
-- Scrolling Layout — Column Manipulation
-- ============================================================
hl.bind(mainMod .. " + X", hl.dsp.layout("consume_or_expel prev")) -- pull previous column into a group, or expel
hl.bind(mainMod .. " + bracketleft", hl.dsp.layout("move -col")) -- shift active column left
hl.bind(mainMod .. " + bracketright", hl.dsp.layout("move +col")) -- shift active column right

-- ============================================================
-- Picture-in-Picture Drag (mouse side button)
-- ============================================================
-- Guards the drag to only fire when the active window is actually a
-- PiP window, so this side button doesn't drag arbitrary windows.
hl.bind("mouse:274", function()
	local active = hl.get_active_window()
	if active ~= nil and active.title == "Picture-in-Picture" then
		hl.dispatch(hl.dsp.window.drag())
	end
end, {
	mouse = true,
	non_consuming = true,
})

-- ============================================================
-- Mouse Wheel Workspace Scroll
-- ============================================================
-- SUPER + wheel switches workspaces relative to the current one.
-- Throttled to one switch per 200ms so a single physical scroll
-- tick (which can fire several scroll events) doesn't blow through
-- multiple workspaces at once.
hl.config({
	binds = {
		scroll_event_delay = 0,
	},
})

local throttled = false

local function throttled_dsp(dsp)
	return function()
		if throttled then return end
		throttled = true
		hl.dispatch(dsp)
		hl.timer(function()
			throttled = false
		end, {
			timeout = 200,
			type = "oneshot",
		})
	end
end

local prevWs = hl.dsp.focus({ workspace = "r-1" })
local nextWs = hl.dsp.focus({ workspace = "r+1" })

hl.bind(mainMod .. " + mouse_down", throttled_dsp(prevWs))
hl.bind(mainMod .. " + mouse_up", throttled_dsp(nextWs))

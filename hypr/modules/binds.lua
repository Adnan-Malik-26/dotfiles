---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- ============================================================
-- Layout-Aware Helper
-- ============================================================
-- Lets a single keybind dispatch different actions depending on
-- the active workspace's tiled layout (scrolling / master / dwindle).
-- bind_table[layout] can be either a dispatcher table (hl.dsp.*)
-- or a raw function for multi-step actions.
local function layout_bind(bind_table)
	return function()
		local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
		if not workspace then
			return
		end
		local layout = workspace.tiled_layout

		if bind_table[layout] then
			local action = bind_table[layout]
			if type(action) == "function" then
				action()
			else
				hl.dispatch(action)
			end
		end
	end
end

-- ============================================================
-- Cursor Zoom Helper
-- ============================================================
-- Clamped 1.0–3.0x zoom, stepped via repeat-hold binds below.
local function zoom(delta)
	local current = hl.get_config("cursor:zoom_factor")
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
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("$HOME/.local/bin/night-mode"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("$HOME/.local/bin/wallpaperSwitcher"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("$HOME/.config/rofi/scripts/powermenu_t5"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("$HOME/.local/bin/waybar-switcher"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("$HOME/.local/bin/switch-layout"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("$HOME/.local/bin/chth"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("qs -c Notifications ipc call notifications toggle"))

-- Notification center (swaync)
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("swaync-client -d"),
	{ description = "Dismiss last notification" })
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.exec_cmd("swaync-client -dA"),
	{ description = "Dismiss all notifications" })

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

-- F: fullscreen on master/dwindle, "fit active" on scrolling (no true fullscreen concept there)
hl.bind(
	mainMod .. " + F",
	layout_bind({
		scrolling = hl.dsp.layout("fit active"),
		master = hl.dsp.window.fullscreen(),
		dwindle = hl.dsp.window.fullscreen(),
	})
)

-- NOTE: was previously layout_bind({ scrolling = "promote", master = "pypr toggle spt" }).
-- Overwritten with a flat pin — confirm this was intentional before it's forgotten again.
hl.bind(mainMod .. " + P", hl.dsp.window.pin())

-- Cycle tiled <-> floating windows (jq check needed since Hyprland has no native "cycle only floating/tiled")
hl.bind("ALT + Space", hl.dsp.exec_cmd(
	'[ "$(hyprctl activewindow -j | jq -r ".floating")" = "true" ] && hyprctl dispatch cyclenext tiled || hyprctl dispatch cyclenext floating'
))

-- ============================================================
-- Focus Mode (scrolling layout only)
-- ============================================================
-- SUPER+M: promote active window to a wide "focus" column
hl.bind(
	mainMod .. " + M",
	layout_bind({
		scrolling = function()
			hl.dispatch(hl.dsp.layout("promote"))
			hl.dispatch(hl.dsp.layout("colresize 0.85"))
			hl.dispatch(hl.dsp.layout("fit active"))
		end,
	})
)
-- SUPER+SHIFT+M: reset column back to 50% width
hl.bind(
	mainMod .. " + SHIFT + M",
	layout_bind({
		scrolling = hl.dsp.layout("colresize 0.5"),
	})
)

-- ============================================================
-- Window Focus Navigation (vim-style HJKL)
-- ============================================================
hl.bind(
	mainMod .. " + H",
	layout_bind({
		scrolling = hl.dsp.layout("focus l"),
		master = hl.dsp.focus({ direction = "l" }),
	})
)
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(
	mainMod .. " + L",
	layout_bind({
		scrolling = hl.dsp.layout("focus r"),
		master = hl.dsp.focus({ direction = "r" }),
	})
)

-- Monitor focus (multi-monitor)
hl.bind(mainMod .. " + CTRL + comma", hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + period", hl.dsp.focus({ monitor = "r" }))

-- ============================================================
-- Move Windows (HJKL + monitor)
-- ============================================================
hl.bind(
	mainMod .. " + CTRL + H",
	layout_bind({
		scrolling = hl.dsp.layout("swapcol l"),
		master = hl.dsp.window.move({ direction = "l" }),
	})
)
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(
	mainMod .. " + CTRL + L",
	layout_bind({
		scrolling = hl.dsp.layout("swapcol r"),
		master = hl.dsp.window.move({ direction = "r" }),
	})
)

-- Move window to another monitor
hl.bind(mainMod .. " + CTRL + SHIFT + comma", hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + CTRL + SHIFT + period", hl.dsp.window.move({ monitor = "r" }))

-- ============================================================
-- Resize Windows (HJKL)
-- ============================================================
hl.bind(
	mainMod .. " + SHIFT + H",
	layout_bind({
		scrolling = hl.dsp.layout("colresize -0.1"),
		master = hl.dsp.exec_cmd("hyprctl dispatch resizeactive -30 0"),
	})
)
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 30"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -30"))
hl.bind(
	mainMod .. " + SHIFT + L",
	layout_bind({
		scrolling = hl.dsp.layout("colresize +0.1"),
		master = hl.dsp.exec_cmd("hyprctl dispatch resizeactive 30 0"),
	})
)

-- ============================================================
-- Workspace Switching (1–0)
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
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("pypr toggle bluetuith"))

-- ============================================================
-- Scrolling Layout Exclusive
-- ============================================================
hl.bind(
	mainMod .. " + X",
	layout_bind({
		scrolling = hl.dsp.layout("consume_or_expel prev"),
	})
)
hl.bind(
	mainMod .. " + bracketleft",
	layout_bind({
		scrolling = hl.dsp.layout("move -col"),
	})
)
hl.bind(
	mainMod .. " + bracketright",
	layout_bind({
		scrolling = hl.dsp.layout("move +col"),
	})
)

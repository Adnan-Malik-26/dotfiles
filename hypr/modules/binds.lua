---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- ========================================
-- Layout-Aware Helper
-- ========================================

local function layout_bind(bind_table)
	return function()
		local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
		if not workspace then
			return
		end
		local layout = workspace.tiled_layout

		if bind_table[layout] then
			-- bind_table values can be a dispatcher table OR a callable function
			local action = bind_table[layout]
			if type(action) == "function" then
				action()
			else
				hl.dispatch(action)
			end
		end
	end
end

-- ========================================
-- Application Launches
-- ========================================

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty -1"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("/home/adnanmalik/dotfiles/rofi/launchers/type-1/launcher.sh"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("helium-browser"))

-- ========================================
-- System & Utilities
-- ========================================

hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("$HOME/.local/bin/night-mode"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("$HOME/.local/bin/wallpaperSwitcher"))

hl.bind(
	mainMod .. " + E",
	hl.dsp.exec_cmd("rofi -modi emoji -show emoji -theme ~/.config/rofi/launchers/type-1/style-2.rasi")
)

hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("$HOME/.config/rofi/scripts/powermenu_t5"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("$HOME/.local/bin/waybar-switcher"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("$HOME/.local/bin/switch-layout"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("$HOME/.local/bin/chth"))

-- ========================================
-- Window Management
-- ========================================

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

-- F: fullscreen on master, fit active on scrolling
hl.bind(
	mainMod .. " + F",
	layout_bind({
		scrolling = hl.dsp.layout("fit active"),
		master = hl.dsp.window.fullscreen(),
		dwindle = hl.dsp.window.fullscreen(),
	})
)

-- ========================================
-- Focus Mode (scrolling only)
-- ========================================

hl.bind(mainMod .. " + M", function()
	layout_bind({
		scrolling = function()
			hl.dispatch(hl.dsp.layout("promote"))
			hl.dispatch(hl.dsp.layout("colresize 0.85"))
			hl.dispatch(hl.dsp.layout("fit active"))
		end,
	})()
end)
hl.bind(
	mainMod .. " + SHIFT + M",
	layout_bind({
		scrolling = hl.dsp.layout("colresize 0.5"),
	})
)

-- ========================================
-- Window Focus
-- ========================================

hl.bind(
	mainMod .. " + H",
	layout_bind({
		scrolling = hl.dsp.layout("focus l"),
		master = hl.dsp.focus({ direction = "l" }), -- FIX: "left" -> "l"
	})
)
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" })) -- FIX: "down" -> "d"
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" })) -- FIX: "up" -> "u"
hl.bind(
	mainMod .. " + L",
	layout_bind({
		scrolling = hl.dsp.layout("focus r"),
		master = hl.dsp.focus({ direction = "r" }), -- FIX: "right" -> "r"
	})
)

hl.bind(
	"ALT + Space",
	hl.dsp.exec_cmd(
		"$(hyprctl activewindow -j | jq '.floating') && hyprctl dispatch cyclenext tiled || hyprctl dispatch cyclenext floating"
	)
)

-- ========================================
-- Move Windows
-- ========================================

hl.bind(
	mainMod .. " + CTRL + H",
	layout_bind({
		scrolling = hl.dsp.layout("swapcol l"),
		master = hl.dsp.window.move({ direction = "l" }), -- FIX: "left" -> "l"
	})
)
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "d" })) -- FIX: "down" -> "d"
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "u" })) -- FIX: "up" -> "u"
hl.bind(
	mainMod .. " + CTRL + L",
	layout_bind({
		scrolling = hl.dsp.layout("swapcol r"),
		master = hl.dsp.window.move({ direction = "r" }), -- FIX: "right" -> "r"
	})
)

-- ========================================
-- Resize Windows
-- ========================================

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

-- ========================================
-- Workspace Switching
-- ========================================

for i = 1, 10 do
	local key = i % 10

	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- ========================================
-- Mouse Bindings
-- ========================================

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ========================================
-- Screenshots
-- ========================================

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots/"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots/"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots/"))

hl.bind("Insert", hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots/"))
hl.bind("SHIFT + Insert", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots/"))
hl.bind(mainMod .. " + Insert", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots/"))

-- ========================================
-- Media Controls
-- ========================================

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("$HOME/.local/bin/volume.sh --toggle"), {
	locked = true,
	repeating = true,
})
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("$HOME/.local/bin/volume.sh --inc"), {
	locked = true,
	repeating = true,
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("$HOME/.local/bin/volume.sh --dec"), {
	locked = true,
	repeating = true,
})

hl.bind("SHIFT + F3", hl.dsp.exec_cmd("$HOME/.local/bin/brightness.sh --inc"), {
	locked = true,
	repeating = true,
})
hl.bind("SHIFT + F2", hl.dsp.exec_cmd("$HOME/.local/bin/brightness.sh --dec"), {
	locked = true,
	repeating = true,
})

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- ========================================
-- Special Modes & Plugins
-- ========================================

hl.bind(
	mainMod .. " + P",
	layout_bind({
		scrolling = hl.dsp.layout("promote"),
		master = hl.dsp.exec_cmd("pypr toggle spt"),
	})
)
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("pypr toggle bluetuith"))

-- ========================================
-- Scrolling Layout Exclusive
-- ========================================

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

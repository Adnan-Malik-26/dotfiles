hl.on("hyprland.start", function()
	local startup = {
		"udiskie",
		"playerctld",
		"hypridle",
		"systemctl --user start hyprpolkitagent",
		"~/.local/bin/gtktheme",
		"kdeconnectd",
		"awww-daemon",
		-- "waybar --config $HOME/.config/waybar/current/config.jsonc --style /home/adnanmalik/.config/waybar/current/style.css", -- waybar
    -- "kanata -c $HOME/dotfiles/kanata/colemak_dh.kbd",
		"brightnessctl -s -d asus::kbd_backlight",
		"nohup $HOME/.local/bin/battery_notify.sh &",
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && systemctl --user start quickshell.service",
    "wl-paste --type text  --watch cliphist store",
    "wl-paste --type image --watch cliphist store",
	}

	for i = 1, #startup do
		hl.exec_cmd(startup[i])
	end
end)

hl.on("hyprland.start", function()
	local startup = {
		"udiskie",
		"playerctld",
		"hypridle",
		"systemctl --user start hyprlokitagent",
		"~/.local/bin/gtktheme",
		"kdeconnectd",
		"swww-daemon",
		"waybar --config /home/adnanmalik/.config/waybar/current/config.jsonc --style /home/adnanmalik/.config/waybar/current/style.css", -- waybar
		"kanata -c /home/adnanmalik/.config/kanata/qwerty.kbd",
		"brightnessctl -s -d asus::kbd_backlight",
		"wl-paste --type text --watch cliphist store",
		"nohup /home/adnanmalik/.local/bin/battery_notify.sh",
		"bash -c 'sleep 2 && swaync'",
	}

	for i = 1, #startup do
		hl.exec_cmd(startup[i])
	end
end)

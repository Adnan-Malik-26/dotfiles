-- Cursor
hl.on("hyprland.start", function()
	hl.exec_cmd('hyprctl setcursor "Vimix Cursors - White" 32')
end)

-- Environment Variables
hl.env("GTK_THEME", "Adwaita-AMOLED")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XCURSOR_THEME", "Vimix Cursors - White")
hl.env("XCURSOR_SIZE", "32")

hl.env("HYPRCURSOR_THEME", "Vimix Cursors - White")
hl.env("HYPRCURSOR_SIZE", "32")

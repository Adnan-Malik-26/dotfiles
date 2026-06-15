-- Cursor
hl.exec_cmd('hyprctl setcursor "Catppuccin Mocha Dark" 24')

-- Environment Variables
hl.env("GTK_THEME", "Colloid-Purple-Dark-Catppuccin")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XCURSOR_THEME", "capitaine-cursors")
hl.env("XCURSOR_SIZE", "24")

-- Papirus Folders Theme
hl.exec_cmd("/opt/papirus-folders/papirus-folders -C cat-mocha-blue --theme Papirus-Dark")

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

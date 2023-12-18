# ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗         ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗
# ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║         ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝
# ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║         ███████╗██║     ██████╔╝██║██████╔╝   ██║   
# ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║         ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   
# ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗    ███████║╚██████╗██║  ██║██║██║        ██║   
# ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝    ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   


#!/bin/bash

# Set the current directory
CURRENT_DIRECTORY=$(pwd)

# Function to create symbolic links with error handling
create_symlink() {
    source_file=$1
    target_file=$2

    if [ -e "$target_file" ]; then
        echo "Symbolic link for $target_file already exists. Skipping..."
    else
        ln -s "$source_file" "$target_file"
        echo "Created symbolic link for $target_file"
    fi
}

# Ensure that target directories exist
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0
mkdir -p ~/.config/hypr
mkdir -p ~/.config/i3
mkdir -p ~/.config/liferea
mkdir -p ~/.config/neofetch
mkdir -p ~/.config/nvim
mkdir -p ~/.config/polybar
mkdir -p ~/.config/qBittorrent
mkdir -p ~/.config/rofi
mkdir -p ~/.config/waybar
mkdir -p ~/.config/wlogout
mkdir -p ~/.config/wal/templates
mkdir -p ~/.local/bin

# Create symbolic links
create_symlink "$CURRENT_DIRECTORY/alacritty/alacritty.yml" "~/.config/alacritty/alacritty.yml"
create_symlink "$CURRENT_DIRECTORY/bashrc/bashrc" "~/.bashrc"
create_symlink "$CURRENT_DIRECTORY/gtk/gtk-3.0" "~/.config/gtk-3.0/"
create_symlink "$CURRENT_DIRECTORY/gtk/gtk-4.0" "~/.config/gtk-4.0/"
create_symlink "$CURRENT_DIRECTORY/hypr" "~/.config/hypr/"
create_symlink "$CURRENT_DIRECTORY/i3" "~/.config/i3/"
create_symlink "$CURRENT_DIRECTORY/liferea" "~/.config/liferea/"
create_symlink "$CURRENT_DIRECTORY/neofetch" "~/.config/neofetch"
create_symlink "$CURRENT_DIRECTORY/nvim" "~/.config/nvim/"
create_symlink "$CURRENT_DIRECTORY/polybar" "~/.config/polybar/"
create_symlink "$CURRENT_DIRECTORY/qBittorrent" "~/.config/qBittorrent/"
create_symlink "$CURRENT_DIRECTORY/rofi" "~/.config/rofi/"
create_symlink "$CURRENT_DIRECTORY/starship/starship.toml" "~/.config/starship.toml"
create_symlink "$CURRENT_DIRECTORY/waybar" "~/.config/waybar/"
create_symlink "$CURRENT_DIRECTORY/wlogout" "~/.config/wlogout/"
create_symlink "$CURRENT_DIRECTORY/scripts/chalac" "~/.local/bin/chalac"
create_symlink "$CURRENT_DIRECTORY/scripts/chchrome" "~/.local/bin/chchrome"
create_symlink "$CURRENT_DIRECTORY/scripts/chwal" "~/.local/bin/chwal"
create_symlink "$CURRENT_DIRECTORY/scripts/getwall" "~/.local/bin/getwall"
create_symlink "$CURRENT_DIRECTORY/scripts/gtk.sh" "~/.local/bin/gtk.sh"
create_symlink "$CURRENT_DIRECTORY/scripts/rofiwifimenu" "~/.local/bin/rofiwifimenu"
create_symlink "$CURRENT_DIRECTORY/scripts/waybar-progress" "~/.local/bin/waybar-progress"
create_symlink "$CURRENT_DIRECTORY/pywaltemplates" "~/.config/wal/templates/"
create_symlink "$CURRENT_DIRECTORY/scripts" "~/.local/bin/colorscript"
create_symlink "$CURRENT_DIRECTORY/scripts/custwall" "~/.local/bin/custwall"
create_symlink "$CURRENT_DIRECTORY/swaylock" "~/.config/swaylock"

echo "Installation complete."

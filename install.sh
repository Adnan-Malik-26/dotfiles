#!/bin/bash

ln -s ~/.dotfiles/alacritty/ ~/.config/alacritty/ 
ln -s ~/.dotfiles/neofetch/ ~/.config/neofetch/ 
ln -s ~/.dotfiles/bashrc/bashrc ~/.bashrc 
ln -s ~/.dotfiles/gtk/gtk-3.0/ ~/.config/gtk-3.0/ 
ln -s ~/.dotfiles/gtk/gtk-4.0/ ~/.config/gtk-4.0/ 
ln -s ~/.dotfiles/hypr/ ~/.config/hypr/ 
ln -s ~/.dotfiles/i3 ~/.config/i3 
ln -s ~/.dotfiles/nvim ~/.config/nvim/ 
ln -s ~/.dotfiles/qBittorrent/ ~/.dotfiles/qBittorrent/ 
ln -s ~/.dotfiles/rofi/ ~/.config/rofi/ 
ln -s ~/.dotfiles/starship/starship.toml ~/.config/starship.toml 
ln -s ~/.dotfiles/swaylock/ ~/.config/swaylock/
ln -s ~/.dotfiles/waybar/ ~/.config/waybar/ 
ln -s ~/.dotfiles/wlogout/ ~/.config/wlogout/ 
ln -s ~/.dotfiles/gitconfig ~/.gitconfig

chmod +x ~/.dotfiles/scripts/chwal 
chmod +x ~/.dotfiles/scripts/autolock.sh
chmod +x ~/.dotfiles/scripts/browser.sh
chmod +x ~/.dotfiles/scripts/chalac
chmod +x ~/.dotfiles/scripts/chchrome
chmod +x ~/.dotfiles/scripts/colorscript.sh
chmod +x ~/.dotfiles/scripts/custwall
chmod +x ~/.dotfiles/scripts/filemanager.sh
chmod +x ~/.dotfiles/scripts/getwall
chmod +x ~/.dotfiles/scripts/gtk.sh
chmod +x ~/.dotfiles/scripts/rofiwifimenu
chmod +x ~/.dotfiles/scripts/wal-discord
chmod +x ~/.dotfiles/scripts/wal-zathura
chmod +x ~/.dotfiles/scripts/wal-telegram
chmod +x ~/.dotfiles/scripts/wallpaper_history
chmod +x ~/.dotfiles/scripts/waybar-progress

ln -s ~/.dotfiles/scripts/chwal 
ln -s ~/.dotfiles/scripts/autolock.sh
ln -s ~/.dotfiles/scripts/browser.sh
ln -s ~/.dotfiles/scripts/chalac
ln -s ~/.dotfiles/scripts/chchrome
ln -s ~/.dotfiles/scripts/colorscript.sh
ln -s ~/.dotfiles/scripts/custwall
ln -s ~/.dotfiles/scripts/filemanager.sh
ln -s ~/.dotfiles/scripts/getwall
ln -s ~/.dotfiles/scripts/gtk.sh
ln -s ~/.dotfiles/scripts/rofiwifimenu
ln -s ~/.dotfiles/scripts/wal-discord
ln -s ~/.dotfiles/scripts/wal-zathura
ln -s ~/.dotfiles/scripts/wal-telegram
ln -s ~/.dotfiles/scripts/wallpaper_history
ln -s ~/.dotfiles/scripts/waybar-progress

#sddm theme
sudo cp ~/.dotfiles/sddm/theme/redrock/ /usr/share/sddm/themes/redrock

echo "Installation complete."

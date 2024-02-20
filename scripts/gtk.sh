#!/bin/bash
gnome_schema="org.gnome.desktop.interface"
gsettings set "$gnome_schema" icon-theme "Catppuccin Mocha"
gsettings set "$gnome_schema" cursor-theme "Bibata-Modern-Ice"
gsettings set "$gnome_schema" font-name "Fira Code Nerd Font Mono Regular"
gsettings set "$gnome_schema" color-scheme "prefer-dark"

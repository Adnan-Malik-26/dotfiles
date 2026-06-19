#!/usr/bin/env bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/walls/mainwalls/"

# Start swww daemon if it's not already running
if ! pgrep -x "swww-daemon" >/dev/null; then
  swww init
  sleep 1
fi

# Pick a random wallpaper from the directory
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)

# If no image found, exit
if [[ -z "$WALLPAPER" ]]; then
  notify-send "Wallpaper Changer" "No images found in $WALLPAPER_DIR"
  exit 1
fi

# Extract filename only
FILENAME=$(basename "$WALLPAPER")

# Change wallpaper with wipe transition
swww img "$WALLPAPER" --transition-type wipe --transition-angle 30 --transition-duration 1.5

# Notify user
notify-send "Wallpaper Changed" "$FILENAME" -i "$WALLPAPER"

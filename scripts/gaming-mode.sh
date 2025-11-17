#!/bin/bash

# Hyprland Gaming Mode Toggle Script
# This script toggles gaming mode on/off

STATE_FILE="/tmp/hyprland_gaming_mode"

enable_gaming_mode() {
  notify-send "Enabling Gaming Mode..."

  hyprctl keyword input:kb_options ""

  pkill -9 kanata

  touch "$STATE_FILE"

  notify-send "Gaming Mode enabled!"
  echo "- Caps lock swap disabled"
  echo "- Kanata killed"
}

disable_gaming_mode() {
  notify-send "Disabling Gaming Mode..."

  hyprctl keyword input:kb_options "caps:swapescape"

  kanata -c ~/.config/kanata/qwerty.kbd &

  # Remove state file
  rm -f "$STATE_FILE"

  notify-send "Gaming Mode disabled!"
  echo "- Caps lock swap re-enabled"
  echo "- (Kanata needs manual restart if desired)"
}

if [ -f "$STATE_FILE" ]; then
  disable_gaming_mode
else
  enable_gaming_mode
fi

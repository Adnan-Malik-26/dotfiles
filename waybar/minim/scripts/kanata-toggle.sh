#!/bin/bash

# Kanata toggle script for Waybar
# Save this as ~/.config/waybar/scripts/kanata-toggle.sh
# Make it executable: chmod +x ~/.config/waybar/scripts/kanata-toggle.sh

check_kanata() {
  pgrep -x kanata >/dev/null
}

toggle_kanata() {
  if check_kanata; then
    # Kanata is running, stop it
    pkill -x kanata
    sleep 0.2
    notify-send "Kanata" "Stopped" -i keyboard -u normal
  else
    # Kanata is not running, start it
    # Adjust the path to your kanata config file
    kanata -c ~/.config/kanata/qwerty.kbd &
    sleep 0.2
    notify-send "Kanata" "Started" -i keyboard -u normal
  fi
  # Force waybar to refresh
  pkill -RTMIN+8 waybar
}

status_kanata() {
  if check_kanata; then
    echo '{"text": "󰌌 Running", "class": "active", "tooltip": "Kanata is running (click to stop)"}'
  else
    echo '{"text": "󰌐 Stopped", "class": "inactive", "tooltip": "Kanata is stopped (click to start)"}'
  fi
}

case "$1" in
toggle)
  toggle_kanata
  ;;
*)
  status_kanata
  ;;
esac

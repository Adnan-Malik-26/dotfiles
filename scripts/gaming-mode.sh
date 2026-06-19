#!/bin/bash
# Hyprland Game Mode Toggle Script
# Optimizes visual performance by toggling Hyprland effects

STATE_FILE="$HOME/.cache/gamemode_state"

# Function to enable game mode
enable_gamemode() {
  echo "🎮 Enabling Game Mode..."

  # Disable Hyprland visual effects
  hyprctl keyword decoration:rounding 0
  hyprctl keyword decoration:blur:enabled false
  hyprctl keyword decoration:drop_shadow false
  hyprctl keyword animations:enabled false

  echo "✓ Hyprland optimized for gaming"

  # Save state
  echo "enabled" >"$STATE_FILE"
  echo "✓ Game Mode ENABLED"
  notify-send "🎮 Game Mode" "Performance mode activated" -t 3000
}

# Function to disable game mode
disable_gamemode() {
  echo "🔄 Disabling Game Mode..."

  # Re-enable Hyprland visual effects (adjust these values to your preferences)
  hyprctl keyword decoration:rounding 10
  hyprctl keyword decoration:blur:enabled true
  hyprctl keyword decoration:drop_shadow true
  hyprctl keyword animations:enabled true

  # Remove state
  rm -f "$STATE_FILE"
  echo "✓ Game Mode DISABLED"
  notify-send "🔄 Game Mode" "Normal mode restored" -t 3000
}

# Check current state
check_state() {
  if [ -f "$STATE_FILE" ]; then
    echo "Game Mode is currently: ENABLED"
  else
    echo "Game Mode is currently: DISABLED"
  fi
}

# Main logic
case "$1" in
on | enable)
  enable_gamemode
  ;;
off | disable)
  disable_gamemode
  ;;
toggle)
  if [ -f "$STATE_FILE" ]; then
    disable_gamemode
  else
    enable_gamemode
  fi
  ;;
status)
  check_state
  ;;
*)
  echo "Usage: $0 {on|off|toggle|status}"
  echo "  on/enable  - Enable game mode"
  echo "  off/disable - Disable game mode"
  echo "  toggle     - Toggle game mode"
  echo "  status     - Check current state"
  exit 1
  ;;
esac

exit 0

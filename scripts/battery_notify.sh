#!/bin/bash

# Minimum battery percentage before warning
THRESHOLD=20
# Check interval (in seconds)
INTERVAL=60

# To track whether we've already warned the user
WARNED=false

while true; do
  # Read battery info
  BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT*/capacity)
  STATUS=$(cat /sys/class/power_supply/BAT*/status)

  if [[ "$STATUS" == "Discharging" ]]; then
    if [[ "$BATTERY_LEVEL" -lt "$THRESHOLD" ]]; then
      if [ "$WARNED" = false ]; then
        notify-send -u critical "Battery Low ⚠️" \
          "Battery at ${BATTERY_LEVEL}%! Please plug in the charger."
        paplay /usr/share/sounds/freedesktop/stereo/dialog-warning.oga 2>/dev/null
        WARNED=true
      fi
    else
      # Reset warning if battery goes above threshold
      WARNED=false
    fi
  else
    # When plugged in or charging, reset warning flag
    WARNED=false
  fi

  sleep "$INTERVAL"
done

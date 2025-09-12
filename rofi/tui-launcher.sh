#!/usr/bin/env bash

dir="$HOME/.config/rofi/"
theme='style-7'

# Map of scratchpad names to labels
declare -A APPS=(
  [htop]="System Monitor"
  [ncdu]="Disk Usage"
  [btop]="Resource Monitor"
  [yazi]="File Manager"
  [nvim]="Text Editor"
  [bluetuith]="Bluetooth"
)

# Extract just the labels for rofi
choices=$(printf "%s\n" "${APPS[@]}")

# Let user pick one
chosen=$(
  echo "$choices" | rofi -dmenu -p "TUI Apps" \
    -theme "${dir}/${theme}.rasi" \
    -theme-str 'element-icon { enabled: false; size: 0px; }'
)

# Exit if nothing selected
[ -z "$chosen" ] && exit 0

# Find the scratchpad name corresponding to the chosen label
for spad in "${!APPS[@]}"; do
  if [[ "${APPS[$spad]}" == "$chosen" ]]; then
    pypr toggle "$spad"
    exit 0
  fi
done
-n "$cmd" ] && pypr toggle "$cmd"

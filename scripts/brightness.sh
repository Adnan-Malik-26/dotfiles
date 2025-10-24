#!/bin/bash
iDir="$HOME/.config/swaync/icons"
notification_timeout=1000
step=10

get_backlight() {
  brightnessctl -m | cut -d, -f4 | sed 's/%//'
}

get_icon() {
  current=$(get_backlight)
  if [ "$current" -le "20" ]; then
    icon="$iDir/brightness-20.png"
  elif [ "$current" -le "40" ]; then
    icon="$iDir/brightness-40.png"
  elif [ "$current" -le "60" ]; then
    icon="$iDir/brightness-60.png"
  elif [ "$current" -le "80" ]; then
    icon="$iDir/brightness-80.png"
  else
    icon="$iDir/brightness-100.png"
  fi
}

notify_user() {
  notify-send -e -h string:x-canonical-private-synchronous:osd -u low -i $icon "Brightness" "$current%"
}

change_brightness() {
  local current_brightness
  current_brightness=$(get_backlight)
  if [[ "$1" == "+${step}%" ]]; then
    new_brightness=$((current_brightness + step))
  elif [[ "$1" == "-${step}%" ]]; then
    new_brightness=$((current_brightness - step))
  fi
  if ((new_brightness < 5)); then
    new_brightness=5
  elif ((new_brightness > 100)); then
    new_brightness=100
  fi
  brightnessctl set "${new_brightness}%"
  get_icon
  current=$new_brightness
  notify_user
}

case "$1" in
"--get")
  get_backlight
  ;;
"--inc")
  change_brightness "+${step}%"
  ;;
"--dec")
  change_brightness "-${step}%"
  ;;
*)
  echo "Usage: $0 {--get|--inc|--dec}"
  exit 1
  ;;
esac

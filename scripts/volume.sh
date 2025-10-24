#!/bin/bash
iDir="$HOME/.config/swaync/icons"
get_volume_num() { pamixer --get-volume; }
is_muted() { pamixer --get-mute | grep -q true; }
get_volume_label() {
  if is_muted; then
    printf "Muted"
  else
    printf "%s%%" "$(get_volume_num)"
  fi
}
get_icon() {
  if is_muted; then
    echo "$iDir/volume-mute.png"
  else
    v="$(get_volume_num)"
    if ((v <= 30)); then
      echo "$iDir/volume-low.png"
    elif ((v <= 60)); then
      echo "$iDir/volume-mid.png"
    else
      echo "$iDir/volume-high.png"
    fi
  fi
}
notify_user() {
  local val label
  if is_muted; then
    val=0
  else
    val="$(get_volume_num)"
  fi
  label="$(get_volume_label)" # FIX: Added command substitution
  notify-send -e -h string:x-canonical-private-synchronous:osd \
    -u low \
    -i "$(get_icon)" \
    "Volume" "$label"
}
inc_volume() {
  if is_muted; then
    toggle_mute
  else
    pamixer -i 5 --allow-boost --set-limit 150
    notify_user
  fi
}
dec_volume() {
  if is_muted; then
    toggle_mute
  else
    pamixer -d 5
    notify_user
  fi
}
toggle_mute() {
  if is_muted; then
    pamixer -u
  else
    pamixer -m
  fi
  notify_user
}
is_mic_muted() { pamixer --default-source --get-mute | grep -q true; }
get_mic_num() { pamixer --default-source --get-volume; }
get_mic_label() {
  if is_mic_muted; then
    printf "Muted"
  else
    printf "%s%%" "$(get_mic_num)" # FIX: Added command substitution
  fi
}
get_mic_icon() {
  if is_mic_muted; then
    echo "$iDir/microphone-mute.png"
  else
    echo "$iDir/microphone.png"
  fi
}
notify_mic_user() {
  local val label
  if is_mic_muted; then
    val=0
  else
    val="$(get_mic_num)"
  fi
  label="$(get_mic_label)" # FIX: Added command substitution
  notify-send -e \
    -h string:x-canonical-private-synchronous:mic_notif \
    -u low \
    -i "$(get_mic_icon)" \
    "Microphone" "$label"
}
toggle_mic() {
  if is_mic_muted; then
    pamixer --default-source -u
  else
    pamixer --default-source -m
  fi
  notify_mic_user
}
inc_mic_volume() {
  if is_mic_muted; then
    toggle_mic
  else
    pamixer --default-source -i 5
  fi
  notify_mic_user
}
dec_mic_volume() {
  if is_mic_muted; then
    toggle_mic
  else
    pamixer --default-source -d 5
  fi
  notify_mic_user
}
case "$1" in
--get) get_volume_label ;;
--inc) inc_volume ;;
--dec) dec_volume ;;
--toggle) toggle_mute ;;
--toggle-mic) toggle_mic ;;
--get-icon) get_icon ;;
--get-mic-icon) get_mic_icon ;;
--mic-inc) inc_mic_volume ;;
--mic-dec) dec_mic_volume ;;
*) get_volume_label ;;
esac

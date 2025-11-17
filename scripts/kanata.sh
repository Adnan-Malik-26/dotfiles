#!/bin/env bash

if [[ $(pidof kanata) ]]; then
  pkill kanata
  notify-send "Killed Kanata"
  exit 0
fi
notify-send "Started Kanata"
kanata -c $HOME/.config/kanata/qwerty.kbd >/dev/null 2>&1
exit 0

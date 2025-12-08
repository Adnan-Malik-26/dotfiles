#!/bin/bash

if pgrep -x "hypridle"; then
  killall hypridle
  notify-send "Caffeine Mode On"
else
  hypridle >/dev/null &
  notify-send "Caffeine Mode OFF"
fi

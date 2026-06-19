#!/bin/bash

blitz_mode=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')

if [ "blitz_mode" = 1 ]; then
  hyprctl --batch "\
    keyword animations:enabled 0; \
    keyword decoration:drop_shadow 0; \
    keyword decoration:blur:enabled 0; \
    keyword decoration:rounding 0; \
    keyword general:gaps_in 0; \
    keyword general:gaps_out 0; \
    keyword general:border_size 1; \
    keyword general:allow_tearing 1; \ "
  exit
fi

hyprctl reload

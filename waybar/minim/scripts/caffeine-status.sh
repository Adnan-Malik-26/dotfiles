#!/bin/bash

if pgrep -x "hypridle"; then
  echo '{"text":"󰾪","class":"disabled","tooltip":"Caffeine: Disabled"}'
else
  echo '{"text":"󰅶","class":"enabled","tooltip":"Caffeine: Enabled"}'
fi

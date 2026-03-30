#!/bin/bash

compgen -c | sort -u | fzf --reverse --prompt "> " --tabstop 4 -e --print-query | tail -n 1 | xargs -r swaymsg -t command exec

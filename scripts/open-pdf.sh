#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
  selected=$1
else
  dir=$(tmux display-message -p -F "#{pane_current_path}")
  selected=$(
    find "$dir" ~/Downloads ~/Documents/Books ~/Documents -mindepth 1 -maxdepth 1 -name "*.pdf" |
      sed "s|^$HOME/||" |
      sk --margin 10% --color=bw
  )
  [[ -n "$selected" ]] && selected="$HOME/$selected"
fi

[[ -z "$selected" ]] && exit 1

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

tmux new-window -n "$selected_name" -d zathura "$selected"
tmux select-window -l

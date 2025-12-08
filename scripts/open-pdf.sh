#!/usr/bin/env bash

# If a file is passed as argument, use it directly
if [[ $# -eq 1 ]]; then
  selected=$1
else
  dir=$(tmux display-message -p -F "#{pane_current_path}")
  selected=$(
    find "$dir" ~/Downloads ~/Documents/Books/Machine_Learning_AI/ ~/Documents/Books/Algorithms_DataStructures/ ~/Documents/Books/Personal_Development/ ~/Documents/Books/Productivity_Learning/ ~/Documents/Books/Programming_Languages/ ~/Documents/Books/Software_Engineering/ ~/Documents/Books/Systems_Infrastructure/ \
      -mindepth 1 -maxdepth 1 \( \
      -iname "*.pdf" -o -iname "*.epub" -o -iname "*.mobi" \
      \) 2>/dev/null |
      sed "s|^${HOME}/||" |
      sk --margin 10% --color=bw
  )
  [[ -n "$selected" ]] && selected="${HOME}/${selected}"
fi

# Exit if nothing was selected
[[ -z "$selected" ]] && exit 1

# Format tmux window name (avoid dots)
selected_name=$(basename "$selected" | tr '.' '_')

# If tmux isn’t running, start it and open the file
if ! pgrep -x tmux >/dev/null; then
  tmux new-session -d -s reader zathura "$selected"
  tmux attach -t reader
else
  tmux new-window -n "$selected_name" -d zathura "$selected"
  tmux select-window -t "$selected_name"
fi

#!/usr/bin/env bash
# tmux-sessionizer — fast project switcher
# Usage: bind to a key, e.g. bind-key -r f run-shell "tmux new-window '~/.local/bin/tmux-sessionizer'"

DIRS=(
  "$HOME/Dev"
  "$HOME/.notes"
  "$HOME/Dev/projects"
  "$HOME/Dev/learning"
  "$HOME/.config"
)

# Build candidate list: direct children of each dir that are directories
# -maxdepth 1 keeps it O(n) not O(tree) — fast even on large dirs
selected=$(
  find "${DIRS[@]}" \
    -mindepth 1 -maxdepth 1 \
    -type d \
    2>/dev/null \
  | sort -u \
  | fzf --reverse --height=40% --border --prompt="  "
)

[[ -z "$selected" ]] && exit 0

# Sanitize: tmux session names can't contain dots or colons
session_name=$(basename "$selected" | tr ' .:/\\' '_')

if ! tmux has-session -t "=$session_name" 2>/dev/null; then
  tmux new-session -ds "$session_name" -c "$selected"
fi

# Attach or switch depending on whether already inside tmux
if [[ -n "$TMUX" ]]; then
  tmux switch-client -t "=$session_name"
else
  tmux attach-session -t "=$session_name"
fi

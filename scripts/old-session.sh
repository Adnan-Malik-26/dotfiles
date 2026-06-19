#!/usr/bin/env bash

set -euo pipefail

# -----------------------------
# Configuration
# -----------------------------
DIRS=(
  "$HOME/Dev"
  "$HOME"
  "$HOME/.notes"
  "$HOME/Dev/projects"
  "$HOME/Dev/learning"
  "$HOME/.config"
)

MAX_DEPTH=1
open_nvim=false
selected=""

# -----------------------------
# Argument parsing
# -----------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
  --nvim)
    open_nvim=true
    ;;
  --depth)
    MAX_DEPTH="$2"
    shift
    ;;
  *)
    selected="$1"
    ;;
  esac
  shift
done

# -----------------------------
# Dependency checks
# -----------------------------
for cmd in fd fzf tmux; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed."
    exit 1
  fi
done

# -----------------------------
# FZF Selection (if no input)
# -----------------------------
if [[ -z "$selected" ]]; then
  # Existing tmux sessions
  existing_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || true)

  # Find directories
  all_dirs=$(fd --type d --max-depth "$MAX_DEPTH" . "${DIRS[@]}" \
    --exclude .git --exclude node_modules --exclude .cache \
    2>/dev/null | sed "s|^$HOME/||" | sort -u)

  # Combine both
  combined=$(printf "%s\n%s" "$existing_sessions" "$all_dirs" | sort -u)

  # FZF UI
  selected=$(echo "$combined" | fzf \
    --prompt="📁 " \
    --header="Enter = open | Ctrl-D = delete session" \
    --preview 'tmux has-session -t {} 2>/dev/null && tmux list-windows -t {} || ls -la "$HOME/{}" 2>/dev/null' \
    --preview-window=right:60% \
    --height=60% --reverse --border)

  # Clean exit if nothing selected
  [[ -z "$selected" ]] && exit 0
fi

# -----------------------------
# Determine if session or dir
# -----------------------------
if tmux has-session -t "$selected" 2>/dev/null; then
  selected_name="$selected"
else
  selected="$HOME/$selected"

  # Create dir if missing
  if [[ ! -d "$selected" ]]; then
    read -rp "Directory doesn't exist. Create it? (y/n): " yn
    [[ "$yn" == "y" ]] && mkdir -p "$selected" || exit 1
  fi

  # Unique session name from full path
  selected_name=$(echo "$selected" | sed "s|$HOME/||" | tr '/.' '__')
fi

# -----------------------------
# Create session if needed
# -----------------------------
if ! tmux has-session -t "$selected_name" 2>/dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected"

  if [[ "$open_nvim" == true ]]; then
    tmux send-keys -t "$selected_name:1" "clear && nvim ." C-m
  fi
fi

# -----------------------------
# Attach / Switch
# -----------------------------
if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$selected_name"
  sleep 1
else
  tmux attach-session -t "$selected_name"
fi

exit 0

#!/bin/bash

DIRS=(
  "$HOME/Dev/"
  "$HOME"
  "$HOME/.notes"
  "$HOME/Dev/projects"
  "$HOME/Dev/learning"
  "$HOME/.config"
)

MAX_DEPTH=2 # Adjust to search deeper
open_nvim=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --nvim)
    open_nvim=true
    shift
    ;;
  --depth)
    MAX_DEPTH=$2
    shift 2
    ;;
  *)
    selected=$1
    shift
    ;;
  esac
done

# If no directory provided, use fuzzy finder
if [[ -z $selected ]]; then
  # Check if fd is installed
  if ! command -v fd &>/dev/null; then
    echo "Error: fd not found. Please install fd-find"
    sleep 2
    exit 1
  fi

  # Check if fzf is installed
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf not found. Please install fzf"
    sleep 2
    exit 1
  fi

  # Get existing tmux sessions
  existing_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | sort)

  # Get all directories
  all_dirs=$(fd . "${DIRS[@]}" --type=dir --max-depth="$MAX_DEPTH" --full-path --base-directory "$HOME" |
    sed "s|^$HOME/||" | sort)

  # Use fzf to select
  selected=$(echo "$all_dirs" | fzf --prompt="📁 " --header="Enter = switch/create | Esc = cancel" --height=60% --reverse --border)

  # Trim whitespace
  selected=$(echo "$selected" | xargs)

  [[ $selected ]] && selected="$HOME/$selected"
fi

# Exit cleanly if nothing selected (closes popup gracefully)
[[ -z $selected ]] && exit 0

# Verify directory exists
if [[ ! -d $selected ]]; then
  echo "Error: Directory '$selected' does not exist"
  sleep 2
  exit 1
fi

# Create session name from directory basename
selected_name=$(basename "$selected" | tr . _)

# Create session if it doesn't exist
if ! tmux has-session -t "$selected_name" 2>/dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected"

  if [[ $open_nvim == true ]]; then
    tmux send-keys -t "$selected_name:1" "nvim" C-m
  fi
fi

# Switch to the session (works from both inside and outside tmux)
if [[ -n $TMUX ]]; then
  # We're inside tmux, switch client
  tmux switch-client -t "$selected_name"
else
  # We're outside tmux, attach to session
  tmux attach-session -t "$selected_name"
fi

# Explicit exit to ensure popup closes
exit 0

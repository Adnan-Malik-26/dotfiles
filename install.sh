#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

CONFIGS=(
  mpd rmpc ghostty hypr hyprlock kitty nvim rofi swaync tmux waybar zsh oh-my-posh sway pypr
)

# ────────────────────────────────
# UI
# ────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
GRAY="\033[90m"

ok() { echo -e "  ${GREEN}✔${RESET} $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; }
die() {
  echo -e "  ${RED}✖${RESET} $1"
  exit 1
}
info() { echo -e "  ${CYAN}➜${RESET} $1"; }

backup() {
  mkdir -p "$BACKUP_DIR"
  mv "$1" "$BACKUP_DIR/"
  warn "Backed up $(basename "$1")"
}

title() {
  echo -e "\n${BOLD}${CYAN}$1${RESET}"
}

# ────────────────────────────────
# Start
# ────────────────────────────────
clear
echo -e "${BOLD}${CYAN}"
echo "╭──────────────────────────────────────────╮"
echo "│  Canonical Dotfiles Relink (Two-Way)     │"
echo "╰──────────────────────────────────────────╯"
echo -e "${RESET}"

mkdir -p "$CONFIG_DIR"

title "📦 Backup directory"
info "$BACKUP_DIR"

title "🔁 Removing old configs & relinking"

for cfg in "${CONFIGS[@]}"; do
  repo="$DOTFILES_DIR/$cfg"
  home="$CONFIG_DIR/$cfg"

  info "$cfg"

  # ── HOME SIDE ───────────────────────────
  if [[ -e "$home" || -L "$home" ]]; then
    backup "$home"
  fi

  # ── REPO SIDE ───────────────────────────
  if [[ -L "$repo" ]]; then
    backup "$repo"
  fi

  if [[ ! -d "$repo" ]]; then
    die "Repo directory missing: $repo"
  fi

  # ── LINK ────────────────────────────────
  ln -s "$repo" "$home"
  ok "Linked ~/.config/$cfg → repo/$cfg"
done

# ────────────────────────────────
# Done
# ────────────────────────────────
title "✅ Finished"

info "All configs are now:"
echo -e "  ${GRAY}~/.config/* → $DOTFILES_DIR/*${RESET}"

info "Backups stored at:"
echo -e "  ${GRAY}$BACKUP_DIR${RESET}"

echo -e "\n${BOLD}${GREEN}Single source of truth restored ✨${RESET}\n"

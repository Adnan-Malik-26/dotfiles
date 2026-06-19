#!/usr/bin/env bash
# install.sh — dotfiles symlink installer
# Resolves DOTFILES_DIR from the script's own location so it works from any CWD.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config"
BIN_DIR="${HOME}/.local/bin"

# ── Colours ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

info() { echo -e "${BLUE}${BOLD}[INFO]${RESET}  $*"; }
ok() { echo -e "${GREEN}${BOLD}[ OK ]${RESET}  $*"; }
warn() { echo -e "${YELLOW}${BOLD}[WARN]${RESET}  $*"; }
err() { echo -e "${RED}${BOLD}[ERR ]${RESET}  $*" >&2; }

# ── Helpers ────────────────────────────────────────────────────────────────────

# make_symlink <src_abs> <dst_abs>
# Two-way: if dst already exists and is a symlink pointing back to src, skip.
# If dst is a real file/dir, back it up before linking.
make_symlink() {
  local src="$1" dst="$2"

  # Already the correct symlink → nothing to do
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    ok "Already linked: ${dst}"
    return
  fi

  # Backup pre-existing real file/dir or wrong symlink
  if [[ -e "$dst" || -L "$dst" ]]; then
    local bak="${dst}.bak.$(date +%Y%m%d_%H%M%S)"
    warn "Backing up existing ${dst} → ${bak}"
    mv "$dst" "$bak"
  fi

  # Ensure parent directory exists
  mkdir -p "$(dirname "$dst")"

  ln -s "$src" "$dst"
  ok "Linked: ${src} → ${dst}"
}

# ── 1. $HOME/.config/<name> entries ───────────────────────────────────────────
CONFIG_ENTRIES=(
  ghostty
  hypr
  hyprlock
  kanata
  kitty
  mpd
  nvim
  oh-my-posh
  pypr
  rmpc
  rofi
  sway
  swaync
  tmux
  waybar
  wofi
)

info "Linking config directories into ${CONFIG_DIR} …"
mkdir -p "$CONFIG_DIR"

for entry in "${CONFIG_ENTRIES[@]}"; do
  src="${DOTFILES_DIR}/${entry}"
  dst="${CONFIG_DIR}/${entry}"

  if [[ ! -e "$src" ]]; then
    warn "Source not found, skipping: ${src}"
    continue
  fi

  make_symlink "$src" "$dst"
done

# ── 2. scripts/* → $HOME/.local/bin ──────────────────────────────────────────
SCRIPTS_SRC="${DOTFILES_DIR}/scripts"

info "Linking scripts into ${BIN_DIR} …"
mkdir -p "$BIN_DIR"

if [[ ! -d "$SCRIPTS_SRC" ]]; then
  err "scripts/ directory not found at ${SCRIPTS_SRC}"
else
  # Iterate over files (including executables without extension)
  while IFS= read -r -d '' script; do
    name="$(basename "$script")"
    make_symlink "$script" "${BIN_DIR}/${name}"
  done < <(find "$SCRIPTS_SRC" -maxdepth 1 -type f -print0)
fi

# ── 3. zsh/.zshrc → $HOME/.zshrc ─────────────────────────────────────────────
info "Linking .zshrc …"
ZSH_SRC="${DOTFILES_DIR}/zsh/.zshrc"

if [[ ! -f "$ZSH_SRC" ]]; then
  warn "zsh/.zshrc not found at ${ZSH_SRC} — skipping"
else
  make_symlink "$ZSH_SRC" "${HOME}/.zshrc"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}All done.${RESET} Run \`source ~/.zshrc\` or open a new shell."

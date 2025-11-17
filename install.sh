#!/bin/bash

# Dotfiles Installation Script
# This script symlinks dotfiles from the repository to their appropriate locations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
SCRIPTS_DIR="$HOME/.local/bin"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Dotfiles Installation Script  ${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo -e "Dotfiles directory: ${GREEN}$DOTFILES_DIR${NC}"
echo ""

# Function to create a backup of existing files/directories
backup_if_exists() {
  local target=$1
  if [ -e "$target" ] || [ -L "$target" ]; then
    local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Backing up existing: $target -> $backup${NC}"
    mv "$target" "$backup"
  fi
}

# Function to create symlink
create_symlink() {
  local source=$1
  local target=$2

  # Create parent directory if it doesn't exist
  local parent_dir=$(dirname "$target")
  if [ ! -d "$parent_dir" ]; then
    echo -e "${BLUE}Creating directory: $parent_dir${NC}"
    mkdir -p "$parent_dir"
  fi

  # Backup existing file/directory
  backup_if_exists "$target"

  # Create symlink
  echo -e "${GREEN}Linking: $target -> $source${NC}"
  ln -sf "$source" "$target"
}

# Create necessary directories
echo -e "${BLUE}Creating necessary directories...${NC}"
mkdir -p "$CONFIG_DIR"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$HOME/.local/share"

# Symlink configuration directories
echo ""
echo -e "${BLUE}Symlinking configuration files...${NC}"

# Config directories
declare -a config_dirs=(
  "fastfetch"
  "ghostty"
  "hypr"
  "nvim"
  "ohmyposh"
  "rofi"
  "swaync"
  "tmux"
  "waybar"
  "zsh"
)

for dir in "${config_dirs[@]}"; do
  if [ -d "$DOTFILES_DIR/$dir" ]; then
    create_symlink "$DOTFILES_DIR/$dir" "$CONFIG_DIR/$dir"
  fi
done

# Firefox (special location)
if [ -d "$DOTFILES_DIR/firefox" ]; then
  echo -e "${YELLOW}Note: Firefox profile needs manual setup.${NC}"
  echo -e "  1. Find your Firefox profile directory: about:support -> Profile Directory"
  echo -e "  2. Symlink chrome folder: ln -sf $DOTFILES_DIR/firefox/chrome <profile-dir>/chrome"
  echo ""
fi

# Wallpapers
if [ -d "$DOTFILES_DIR/walls" ]; then
  create_symlink "$DOTFILES_DIR/walls" "$HOME/Pictures/walls"
fi

# Symlink scripts to .local/bin
echo ""
echo -e "${BLUE}Symlinking scripts to $SCRIPTS_DIR...${NC}"
if [ -d "$DOTFILES_DIR/scripts" ]; then
  for script in "$DOTFILES_DIR/scripts"/*; do
    if [ -f "$script" ] && [ -x "$script" ]; then
      script_name=$(basename "$script")
      create_symlink "$script" "$SCRIPTS_DIR/$script_name"
    fi
  done
fi

# Symlink zshrc to home directory
echo ""
echo -e "${BLUE}Symlinking shell configuration...${NC}"
if [ -f "$DOTFILES_DIR/zsh/zshrc" ]; then
  create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
fi

# Symlink tmux config to home directory
if [ -f "$DOTFILES_DIR/tmux/tmux.conf" ]; then
  create_symlink "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
fi

# Set executable permissions for scripts
echo ""
echo -e "${BLUE}Setting executable permissions for scripts...${NC}"
if [ -d "$DOTFILES_DIR/scripts" ]; then
  chmod +x "$DOTFILES_DIR/scripts"/*
fi

if [ -d "$DOTFILES_DIR/rofi/applets/bin" ]; then
  chmod +x "$DOTFILES_DIR/rofi/applets/bin"/*
fi

if [ -d "$DOTFILES_DIR/rofi/launchers" ]; then
  find "$DOTFILES_DIR/rofi/launchers" -name "*.sh" -exec chmod +x {} \;
fi

if [ -d "$DOTFILES_DIR/rofi/powermenu" ]; then
  find "$DOTFILES_DIR/rofi/powermenu" -name "*.sh" -exec chmod +x {} \;
fi

# Post-installation notes
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Installation Complete! ✓      ${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}Post-installation steps:${NC}"
echo ""
echo -e "1. ${BLUE}Reload your shell:${NC}"
echo -e "   source ~/.zshrc"
echo ""
echo -e "2. ${BLUE}Firefox setup (manual):${NC}"
echo -e "   - Open Firefox and navigate to: about:support"
echo -e "   - Find your Profile Directory"
echo -e "   - Run: ln -sf $DOTFILES_DIR/firefox/chrome <profile-directory>/chrome"
echo ""
echo -e "3. ${BLUE}Hyprland:${NC}"
echo -e "   - Restart Hyprland or reload config: hyprctl reload"
echo ""
echo -e "4. ${BLUE}Waybar theme selection:${NC}"
echo -e "   - Current waybar theme symlink points to: waybar/current"
echo -e "   - Change theme by updating the symlink to your preferred style"
echo ""
echo -e "5. ${BLUE}Install dependencies if needed:${NC}"
echo -e "   - Run ./packinstall.sh"
echo ""
echo -e "${BLUE}Backup files created with timestamp in case you need to restore.${NC}"
echo ""

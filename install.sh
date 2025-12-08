#!/bin/bash

# Dotfiles Installation Script
# This script copies all configuration files to their appropriate locations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Function to print colored messages
print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Function to backup existing config
backup_config() {
  local target="$1"
  if [ -e "$target" ]; then
    local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    print_warning "Backing up existing config: $target -> $backup"
    mv "$target" "$backup"
  fi
}

# Function to copy directory with backup
copy_config() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    print_warning "Source not found: $src"
    return
  fi

  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$dest")"

  # Backup if destination exists
  backup_config "$dest"

  # Copy the configuration
  cp -r "$src" "$dest"
  print_success "Installed: $dest"
}

# Main installation function
install_dotfiles() {
  print_info "Starting dotfiles installation..."
  print_info "Script directory: $SCRIPT_DIR"
  print_info "Config directory: $CONFIG_DIR"

  # Create .config directory if it doesn't exist
  mkdir -p "$CONFIG_DIR"

  # Install configurations
  print_info "\n=== Installing configurations ==="

  # fastfetch
  copy_config "$SCRIPT_DIR/fastfetch" "$CONFIG_DIR/fastfetch"

  # ghostty
  copy_config "$SCRIPT_DIR/ghostty" "$CONFIG_DIR/ghostty"

  # hypr
  copy_config "$SCRIPT_DIR/hypr" "$CONFIG_DIR/hypr"

  # hyprlock
  copy_config "$SCRIPT_DIR/hyprlock" "$CONFIG_DIR/hyprlock"

  # kitty
  copy_config "$SCRIPT_DIR/kitty" "$CONFIG_DIR/kitty"

  # nvim
  copy_config "$SCRIPT_DIR/nvim" "$CONFIG_DIR/nvim"

  # oh-my-posh
  copy_config "$SCRIPT_DIR/oh-my-posh" "$CONFIG_DIR/oh-my-posh"

  # rofi
  copy_config "$SCRIPT_DIR/rofi" "$CONFIG_DIR/rofi"

  # scripts
  copy_config "$SCRIPT_DIR/scripts" "$CONFIG_DIR/scripts"

  # swaync
  copy_config "$SCRIPT_DIR/swaync" "$CONFIG_DIR/swaync"

  # tmux
  copy_config "$SCRIPT_DIR/tmux" "$CONFIG_DIR/tmux"

  # waybar
  copy_config "$SCRIPT_DIR/waybar" "$CONFIG_DIR/waybar"

  # zsh
  if [ -f "$SCRIPT_DIR/zsh/zshrc" ]; then
    backup_config "$HOME/.zshrc"
    cp "$SCRIPT_DIR/zsh/zshrc" "$HOME/.zshrc"
    print_success "Installed: $HOME/.zshrc"
  fi

  # Make scripts executable
  print_info "\n=== Making scripts executable ==="
  if [ -d "$CONFIG_DIR/scripts" ]; then
    chmod +x "$CONFIG_DIR/scripts"/*
    print_success "Made scripts executable"
  fi

  if [ -d "$CONFIG_DIR/rofi/launchers" ]; then
    find "$CONFIG_DIR/rofi" -name "*.sh" -exec chmod +x {} \;
    print_success "Made rofi scripts executable"
  fi

  if [ -d "$CONFIG_DIR/waybar" ]; then
    find "$CONFIG_DIR/waybar" -name "*.sh" -o -name "*.py" -exec chmod +x {} \;
    print_success "Made waybar scripts executable"
  fi

  if [ -d "$CONFIG_DIR/hyprlock/scripts" ]; then
    chmod +x "$CONFIG_DIR/hyprlock/scripts"/*
    print_success "Made hyprlock scripts executable"
  fi

  print_success "\n=== Installation complete! ==="
  print_info "Your dotfiles have been installed to $CONFIG_DIR"
  print_info "Backups of existing configs were created with .backup.TIMESTAMP extension"
  print_warning "\nNote: You may need to:"
  echo "  1. Restart your window manager or reboot"
  echo "  2. Source your .zshrc: source ~/.zshrc"
  echo "  3. Install required dependencies (fonts, packages, etc.)"
}

# Function to show usage
show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
    -h, --help      Show this help message
    -n, --dry-run   Show what would be installed without actually installing

Description:
    This script installs dotfiles from the current directory to ~/.config/
    Existing configurations will be backed up automatically.

EOF
}

# Parse command line arguments
DRY_RUN=false
while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    show_usage
    exit 0
    ;;
  -n | --dry-run)
    DRY_RUN=true
    print_info "DRY RUN MODE - No changes will be made"
    shift
    ;;
  *)
    print_error "Unknown option: $1"
    show_usage
    exit 1
    ;;
  esac
done

# Run installation
if [ "$DRY_RUN" = true ]; then
  print_warning "Dry run mode - would install the following:"
  echo "  - fastfetch -> $CONFIG_DIR/fastfetch"
  echo "  - ghostty -> $CONFIG_DIR/ghostty"
  echo "  - hypr -> $CONFIG_DIR/hypr"
  echo "  - hyprlock -> $CONFIG_DIR/hyprlock"
  echo "  - kitty -> $CONFIG_DIR/kitty"
  echo "  - nvim -> $CONFIG_DIR/nvim"
  echo "  - oh-my-posh -> $CONFIG_DIR/oh-my-posh"
  echo "  - rofi -> $CONFIG_DIR/rofi"
  echo "  - scripts -> $CONFIG_DIR/scripts"
  echo "  - swaync -> $CONFIG_DIR/swaync"
  echo "  - tmux -> $CONFIG_DIR/tmux"
  echo "  - waybar -> $CONFIG_DIR/waybar"
  echo "  - zshrc -> $HOME/.zshrc"
else
  install_dotfiles
fi

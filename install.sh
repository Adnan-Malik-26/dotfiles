#!/bin/env bash

# Dotfiles Installation Script
# This script installs dotfiles with backup functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Print functions
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

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
  print_error "This script is intended for Linux systems only."
  exit 1
fi

# Create backup directory
create_backup_dir() {
  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    print_info "Created backup directory: $BACKUP_DIR"
  fi
}

# Backup existing config
backup_config() {
  local config_name=$1
  local config_path="$CONFIG_DIR/$config_name"

  if [ -e "$config_path" ]; then
    print_warning "Backing up existing $config_name"
    mv "$config_path" "$BACKUP_DIR/"
    return 0
  fi
  return 1
}

# Create symlink
create_symlink() {
  local source=$1
  local target=$2

  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$target")"

  # Remove existing symlink or file
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    print_warning "File exists at $target, backing up..."
    mv "$target" "$BACKUP_DIR/"
  fi

  # Create symlink
  ln -sf "$source" "$target"
  print_success "Linked $source -> $target"
}

# Install configurations
install_configs() {
  print_info "Installing configurations..."

  # Ensure .config directory exists
  mkdir -p "$CONFIG_DIR"

  # List of configs to install
  local configs=(
    "fastfetch"
    "firefox"
    "ghostty"
    "hypr"
    "kitty"
    "nvim"
    "rofi"
    "swaync"
    "tmux"
    "waybar"
  )

  for config in "${configs[@]}"; do
    if [ -d "$DOTFILES_DIR/$config" ]; then
      backup_config "$config"
      create_symlink "$DOTFILES_DIR/$config" "$CONFIG_DIR/$config"
    else
      print_warning "Config directory not found: $config"
    fi
  done
}

# Install scripts
install_scripts() {
  print_info "Installing scripts..."

  local script_dir="$HOME/.local/bin"
  mkdir -p "$script_dir"

  if [ -d "$DOTFILES_DIR/scripts" ]; then
    for script in "$DOTFILES_DIR/scripts"/*; do
      if [ -f "$script" ]; then
        script_name=$(basename "$script")
        create_symlink "$script" "$script_dir/$script_name"
        chmod +x "$script"
      fi
    done
    print_success "Scripts installed to $script_dir"
  fi
}

# Install wallpapers
install_wallpapers() {
  print_info "Installing wallpapers..."

  local wall_dir="$HOME/Pictures/wallpapers"
  mkdir -p "$wall_dir"

  if [ -d "$DOTFILES_DIR/walls" ]; then
    for wall in "$DOTFILES_DIR/walls"/*; do
      if [ -f "$wall" ]; then
        cp "$wall" "$wall_dir/"
      fi
    done
    print_success "Wallpapers copied to $wall_dir"
  fi
}

# Check dependencies
check_dependencies() {
  print_info "Checking dependencies..."

  local deps=(
    "hyprland"
    "waybar"
    "rofi"
    "swaync"
    "kitty"
    "nvim"
    "tmux"
    "fastfetch"
  )

  local missing_deps=()

  for dep in "${deps[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      missing_deps+=("$dep")
    fi
  done

  if [ ${#missing_deps[@]} -gt 0 ]; then
    print_warning "Missing dependencies: ${missing_deps[*]}"
    print_info "You may want to run './packinstall.sh' to install missing packages"
  else
    print_success "All dependencies are installed"
  fi
}

# Post-install instructions
post_install() {
  print_info "Post-installation steps:"
  echo ""
  echo "1. Add ~/.local/bin to your PATH if not already:"
  echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
  echo "2. Reload your shell configuration or restart your terminal"
  echo ""
  echo "3. For Hyprland, logout and login again"
  echo ""
  echo "4. Firefox theme requires manual setup:"
  echo "   - Copy chrome folder to your Firefox profile directory"
  echo "   - Enable 'toolkit.legacyUserProfileCustomizations.stylesheets' in about:config"
  echo ""
  if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
    echo "5. Your old configs are backed up at: $BACKUP_DIR"
    echo ""
  fi
}

# Main installation
main() {
  echo ""
  print_info "====== Dotfiles Installation ======"
  echo ""
  print_info "This will install dotfiles from: $DOTFILES_DIR"
  print_info "Target directory: $CONFIG_DIR"
  echo ""

  read -p "Continue with installation? (y/N) " -n 1 -r
  echo ""

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installation cancelled"
    exit 0
  fi

  create_backup_dir
  check_dependencies
  install_configs
  install_scripts
  install_wallpapers

  echo ""
  print_success "Installation completed successfully!"
  echo ""
  post_install
}

# Run main function
main

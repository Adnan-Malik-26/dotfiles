#!/usr/bin/env bash

# Dotfiles Installation Script
# Installs configuration files using symlinks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get the directory where the script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Print functions
print_header() {
  echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${MAGENTA}  $1${NC}"
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

print_step() {
  echo -e "${BOLD}${BLUE}➜${NC} $1"
}

# Banner
print_banner() {
  echo -e "${CYAN}"
  cat <<"EOF"
    ____        __  _____ __         
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  ) 
/_____/\____/\__/_/ /_/_/\___/____/  
                                      
    Installation Script
EOF
  echo -e "${NC}"
}

# Create backup if file/directory exists
backup_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    print_warning "Backing up existing: $(basename "$target")"
    mv "$target" "$BACKUP_DIR/"
    return 0
  fi
  return 1
}

# Create symlink
create_symlink() {
  local source="$1"
  local target="$2"

  # Remove existing symlink if it exists
  if [[ -L "$target" ]]; then
    rm "$target"
  fi

  # Create parent directory if it doesn't exist
  local parent_dir="$(dirname "$target")"
  if [[ ! -d "$parent_dir" ]]; then
    mkdir -p "$parent_dir"
    print_info "Created directory: $parent_dir"
  fi

  # Create symlink
  if ln -s "$source" "$target"; then
    print_success "Linked: $(basename "$target")"
    return 0
  else
    print_error "Failed to link: $(basename "$target")"
    return 1
  fi
}

# Main installation function
install_dotfiles() {
  print_banner

  print_header "Starting Dotfiles Installation"
  print_info "Dotfiles directory: ${DOTFILES_DIR}"
  print_info "Config directory: ${CONFIG_DIR}"

  # Ensure .config directory exists
  if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir -p "$CONFIG_DIR"
    print_success "Created $CONFIG_DIR"
  fi

  # List of directories to symlink
  local dirs=(
    "fastfetch"
    "ghostty"
    "hypr"
    "hyprlock"
    "kitty"
    "nvim"
    "oh-my-posh"
    "rofi"
    "scripts"
    "swaync"
    "tmux"
    "waybar"
    "zsh"
  )

  print_header "Installing Configuration Files"

  local success_count=0
  local total_count=${#dirs[@]}

  for dir in "${dirs[@]}"; do
    print_step "Processing: ${BOLD}$dir${NC}"

    local source="$DOTFILES_DIR/$dir"
    local target="$CONFIG_DIR/$dir"

    if [[ ! -d "$source" ]]; then
      print_warning "Source directory not found: $dir (skipping)"
      continue
    fi

    # Backup existing files
    backup_if_exists "$target"

    # Create symlink
    if create_symlink "$source" "$target"; then
      ((success_count++))
    fi

    echo ""
  done

  print_header "Making Scripts Executable"

  # Make scripts executable
  if [[ -d "$DOTFILES_DIR/scripts" ]]; then
    find "$DOTFILES_DIR/scripts" -type f -exec chmod +x {} \;
    print_success "Set execute permissions on scripts"
  fi

  if [[ -d "$DOTFILES_DIR/rofi/launchers" ]]; then
    find "$DOTFILES_DIR/rofi/launchers" -type f -name "*.sh" -exec chmod +x {} \;
    find "$DOTFILES_DIR/rofi/powermenu" -type f -name "*.sh" -exec chmod +x {} \;
    find "$DOTFILES_DIR/rofi/applets/bin" -type f -name "*.sh" -exec chmod +x {} \;
    print_success "Set execute permissions on rofi scripts"
  fi

  if [[ -d "$DOTFILES_DIR/waybar" ]]; then
    find "$DOTFILES_DIR/waybar" -type f -name "*.sh" -exec chmod +x {} \;
    find "$DOTFILES_DIR/waybar" -type f -name "*.py" -exec chmod +x {} \;
    print_success "Set execute permissions on waybar scripts"
  fi

  if [[ -d "$DOTFILES_DIR/hyprlock/scripts" ]]; then
    find "$DOTFILES_DIR/hyprlock/scripts" -type f -name "*.sh" -exec chmod +x {} \;
    print_success "Set execute permissions on hyprlock scripts"
  fi

  print_header "Installation Summary"

  echo -e "${BOLD}Results:${NC}"
  echo -e "  ${GREEN}Successfully linked:${NC} $success_count/$total_count configurations"

  if [[ -d "$BACKUP_DIR" ]]; then
    echo -e "  ${YELLOW}Backups saved to:${NC} $BACKUP_DIR"
  else
    echo -e "  ${GREEN}No backups needed${NC} (no existing files found)"
  fi

  print_header "Next Steps"

  echo -e "${BOLD}Recommended actions:${NC}"
  echo -e "  1. Review your configurations in ${CYAN}$CONFIG_DIR${NC}"
  echo -e "  2. Restart your window manager or relog"
  echo -e "  3. Check theme symlinks point to your preferred theme"
  echo -e "  4. Run any additional setup scripts if needed"

  echo -e "\n${GREEN}${BOLD}Installation complete!${NC} 🎉\n"
}

# Uninstall function
uninstall_dotfiles() {
  print_banner
  print_header "Uninstalling Dotfiles"

  print_warning "This will remove all symlinked configurations!"
  read -p "Are you sure you want to continue? (y/N) " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Uninstall cancelled"
    exit 0
  fi

  local dirs=(
    "fastfetch" "ghostty" "hypr" "hyprlock" "kitty"
    "nvim" "oh-my-posh" "rofi" "scripts" "swaync"
    "tmux" "waybar" "zsh"
  )

  for dir in "${dirs[@]}"; do
    local target="$CONFIG_DIR/$dir"
    if [[ -L "$target" ]]; then
      rm "$target"
      print_success "Removed: $dir"
    fi
  done

  print_success "Uninstall complete!"
}

# Show help
show_help() {
  cat <<EOF
Dotfiles Installation Script

Usage: $0 [OPTION]

Options:
    install     Install dotfiles using symlinks (default)
    uninstall   Remove all dotfile symlinks
    help        Show this help message

Examples:
    $0              # Install dotfiles
    $0 install      # Install dotfiles
    $0 uninstall    # Remove dotfiles

EOF
}

# Main script logic
main() {
  case "${1:-install}" in
  install)
    install_dotfiles
    ;;
  uninstall)
    uninstall_dotfiles
    ;;
  help | --help | -h)
    show_help
    ;;
  *)
    print_error "Unknown option: $1"
    show_help
    exit 1
    ;;
  esac
}

# Run main function
main "$@"

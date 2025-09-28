#!/bin/bash

# Dotfiles Install Script
# This script symlinks configuration files to their appropriate locations

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located (dotfiles repo root)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN="$HOME/.local/bin"

# Print colored output
print_status() {
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

# Create directory if it doesn't exist
create_dir() {
  if [[ ! -d "$1" ]]; then
    mkdir -p "$1"
    print_status "Created directory: $1"
  fi
}

# Create symlink with backup
create_symlink() {
  local source="$1"
  local target="$2"

  # Validate source exists
  if [[ ! -e "$source" ]]; then
    print_error "Source does not exist: $source"
    return 1
  fi

  # Create target directory if it doesn't exist
  create_dir "$(dirname "$target")"

  # If target already exists
  if [[ -e "$target" ]] || [[ -L "$target" ]]; then
    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
      print_status "Symlink already exists: $target -> $source"
      return 0
    else
      # Backup existing file/directory
      local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
      mv "$target" "$backup"
      print_warning "Backed up existing file: $target -> $backup"
    fi
  fi

  # Create the symlink
  ln -sf "$source" "$target"
  print_success "Created symlink: $target -> $source"
}

print_status "Starting dotfiles installation..."
print_status "Dotfiles directory: $DOTFILES_DIR"

# Ensure required directories exist
create_dir "$CONFIG_DIR"
create_dir "$LOCAL_BIN"

# Firefox configuration
print_status "Setting up Firefox configuration..."
FIREFOX_PROFILE_DIR="$HOME/.mozilla/firefox"
if [[ -d "$FIREFOX_PROFILE_DIR" ]]; then
  # Find the default profile directory
  PROFILE=$(find "$FIREFOX_PROFILE_DIR" -name "*.default*" -type d | head -1)
  if [[ -n "$PROFILE" ]]; then
    create_dir "$PROFILE/chrome"
    
    # Check if individual files exist before symlinking
    if [[ -f "$DOTFILES_DIR/firefox/userChrome.css" ]]; then
      create_symlink "$DOTFILES_DIR/firefox/userChrome.css" "$PROFILE/chrome/userChrome.css"
    fi
    
    if [[ -f "$DOTFILES_DIR/firefox/userContent.css" ]]; then
      create_symlink "$DOTFILES_DIR/firefox/userContent.css" "$PROFILE/chrome/userContent.css"
    fi
    
    if [[ -f "$DOTFILES_DIR/firefox/user.js" ]]; then
      create_symlink "$DOTFILES_DIR/firefox/user.js" "$PROFILE/user.js"
    fi
    
    # Symlink the entire theme directory if it exists
    if [[ -d "$DOTFILES_DIR/firefox/theme" ]]; then
      create_symlink "$DOTFILES_DIR/firefox/theme" "$PROFILE/chrome/theme"
    fi
    
    print_success "Firefox configuration linked to profile: $PROFILE"
  else
    print_warning "No Firefox profile found. Start Firefox first to create a profile."
  fi
else
  print_warning "Firefox not installed or profile directory not found."
fi

# Configuration files that go directly to ~/.config
CONFIG_APPS=(
  "fastfetch"
  "ghostty"
  "hypr"
  "kitty"
  "nvim"
  "rofi"
  "swaync"
  "tmux"
  "waybar"
)

print_status "Setting up application configurations..."
for app in "${CONFIG_APPS[@]}"; do
  if [[ -d "$DOTFILES_DIR/$app" ]]; then
    create_symlink "$DOTFILES_DIR/$app" "$CONFIG_DIR/$app"
  else
    print_warning "Directory not found: $DOTFILES_DIR/$app"
  fi
done

# Handle nvim-lua separately if it exists (some people prefer this structure)
if [[ -d "$DOTFILES_DIR/nvim-lua" ]]; then
  print_status "Found nvim-lua directory, linking as alternative nvim config..."
  create_symlink "$DOTFILES_DIR/nvim-lua" "$CONFIG_DIR/nvim-lua"
fi

# Scripts that go to ~/.local/bin
print_status "Setting up scripts..."
if [[ -d "$DOTFILES_DIR/scripts" ]]; then
  # Check if scripts directory has any files
  if [[ -n "$(find "$DOTFILES_DIR/scripts" -maxdepth 1 -type f)" ]]; then
    for script in "$DOTFILES_DIR/scripts"/*; do
      if [[ -f "$script" ]]; then
        script_name=$(basename "$script")
        create_symlink "$script" "$LOCAL_BIN/$script_name"
        
        # Make script executable if it isn't already
        if [[ ! -x "$script" ]]; then
          chmod +x "$script"
          print_status "Made script executable: $script"
        fi
      fi
    done

    # Add ~/.local/bin to PATH if not already there
    if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
      print_status "Adding $LOCAL_BIN to PATH..."

      # Add to .bashrc if it exists
      if [[ -f "$HOME/.bashrc" ]]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
          echo "" >>"$HOME/.bashrc"
          echo "# Add ~/.local/bin to PATH" >>"$HOME/.bashrc"
          echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
          print_success "Added to ~/.bashrc"
        fi
      fi

      # Add to .zshrc if it exists
      if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc"; then
          echo "" >>"$HOME/.zshrc"
          echo "# Add ~/.local/bin to PATH" >>"$HOME/.zshrc"
          echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.zshrc"
          print_success "Added to ~/.zshrc"
        fi
      fi

      print_warning "Restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to update PATH"
    else
      print_status "$LOCAL_BIN is already in PATH"
    fi
  else
    print_warning "Scripts directory is empty: $DOTFILES_DIR/scripts"
  fi
else
  print_warning "Scripts directory not found: $DOTFILES_DIR/scripts"
fi

# Wallpapers
print_status "Setting up wallpapers..."
if [[ -d "$DOTFILES_DIR/walls" ]]; then
  create_dir "$HOME/Pictures"
  create_symlink "$DOTFILES_DIR/walls" "$HOME/Pictures/wallpapers"
else
  print_warning "Wallpapers directory not found: $DOTFILES_DIR/walls"
fi

# Set up Tmux Plugin Manager if tmux config exists
if [[ -d "$DOTFILES_DIR/tmux" ]]; then
  print_status "Setting up Tmux Plugin Manager..."
  TPM_DIR="$HOME/.tmux/plugins/tpm"
  
  if [[ ! -d "$TPM_DIR" ]]; then
    print_status "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    print_success "TPM installed. Run 'prefix + I' in tmux to install plugins."
  else
    print_status "TPM already installed"
  fi
fi

print_success "Installation complete!"

# Validation check
print_status "Validating installation..."
validation_errors=0

# Check critical symlinks
for app in "${CONFIG_APPS[@]}"; do
  if [[ -d "$DOTFILES_DIR/$app" ]]; then
    if [[ ! -L "$CONFIG_DIR/$app" ]]; then
      print_error "Symlink validation failed: $CONFIG_DIR/$app"
      ((validation_errors++))
    fi
  fi
done

if [[ $validation_errors -eq 0 ]]; then
  print_success "All validations passed!"
else
  print_error "Found $validation_errors validation errors"
fi

# Post-installation notes
cat <<EOF

${GREEN}=== Post-Installation Notes ===${NC}

1. ${YELLOW}Firefox:${NC}
   - Enable toolkit.legacyUserProfileCustomizations.stylesheets in about:config
   - Restart Firefox to apply userChrome.css changes

2. ${YELLOW}Hyprland:${NC}
   - Make sure all dependencies are installed
   - Restart Hyprland or reload configuration: Super + Shift + R

3. ${YELLOW}Tmux:${NC}
   - TPM has been installed automatically
   - Install plugins: Press prefix + I in tmux
   - Reload tmux config: prefix + r

4. ${YELLOW}Neovim:${NC}
   - Run :checkhealth in nvim to verify setup
   - Install language servers as needed

5. ${YELLOW}Scripts:${NC}
   - Scripts are now available in PATH
   - Some scripts may require additional dependencies
   - Check individual script documentation

6. ${YELLOW}Waybar:${NC}
   - Make sure waybar scripts have proper permissions
   - Restart waybar if running: pkill waybar && waybar &

7. ${YELLOW}General:${NC}
   - Some applications may need to be restarted to pick up new configurations
   - Logout and login again for full effect
   - Check application-specific documentation for additional setup steps

${GREEN}Happy customizing!${NC}

EOF

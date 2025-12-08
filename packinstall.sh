#!/bin/env bash

# Essential Arch Linux Package Installation Script
# This script installs the most important packages from your system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
  print_error "This script should not be run as root!"
  exit 1
fi

# Install yay AUR helper if not present
if ! command -v yay &>/dev/null; then
  print_status "Installing yay AUR helper..."
  mkdir -p ~/Downloads/gitthings
  cd ~/Downloads/gitthings
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ~
  print_success "yay AUR helper installed successfully!"
else
  print_status "yay AUR helper already installed."
fi

# Install yay AUR helper if not present
if ! command -v yay &>/dev/null; then
  print_status "Installing yay AUR helper..."
  mkdir -p ~/Downloads/gitthings
  cd ~/Downloads/gitthings
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ~
  print_success "yay AUR helper installed successfully!"
else
  print_status "yay AUR helper already installed."
fi

print_status "Starting installation of essential packages..."

# Core System Packages
print_status "Installing core system packages..."
sudo pacman -S --needed --noconfirm \
  base base-devel linux linux-firmware \
  grub efibootmgr \
  networkmanager dhcpcd \
  sudo \
  archlinux-keyring

# Boot and Hardware
print_status "Installing boot and hardware support..."
sudo pacman -S --needed --noconfirm \
  intel-ucode \
  nvidia nvidia-utils nvidia-settings \
  bluez bluez-utils \
  alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack \
  brightnessctl

# Essential CLI Tools
print_status "Installing essential CLI tools..."
sudo pacman -S --needed --noconfirm \
  git vim nano \
  curl wget \
  unzip unrar zip \
  htop btop \
  tree \
  ripgrep \
  fzf \
  zsh \
  tmux \
  openssh \
  rsync

# Development Tools
print_status "Installing development tools..."
sudo pacman -S --needed --noconfirm \
  gcc gcc-libs \
  python python-pip \
  nodejs npm \
  go \
  git github-cli \
  cmake make \
  gdb

# Install Rust using rustup
print_status "Installing Rust using rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env

# Hyprland and Wayland
print_status "Installing Hyprland and Wayland components..."
sudo pacman -S --needed --noconfirm \
  waybar \
  dunst \
  rofi \
  alacritty kitty \
  wl-clipboard \
  xdg-desktop-portal-hyprland \
  grim slurp \
  swaybg \
  polkit-gnome

# Install Hyprland from AUR
print_status "Installing Hyprland from AUR..."
yay -S --needed --noconfirm hyprland-meta-git

# Fonts and Themes
print_status "Installing fonts and themes..."
sudo pacman -S --needed --noconfirm \
  ttf-dejavu ttf-liberation \
  noto-fonts-emoji \
  papirus-icon-theme \
  adwaita-icon-theme \
  gtk3 gtk4

print_status "Installing Nerd Fonts from AUR..."
yay -S --needed --noconfirm \
  ttf-jetbrains-mono-nerd \
  ttf-firacode-nerd \
  ttf-hack-nerd

# Media and Graphics
print_status "Installing media and graphics packages..."
sudo pacman -S --needed --noconfirm \
  firefox \
  thunar \
  chromium \
  mpv \
  gimp \
  obs-studio \
  ffmpeg \
  imagemagick

# File Management
print_status "Installing file management tools..."
sudo pacman -S --needed --noconfirm \
  thunar \
  gvfs \
  udisks2 \
  ntfs-3g

# System Utilities
print_status "Installing system utilities..."
sudo pacman -S --needed --noconfirm \
  reflector \
  pacman-contrib \
  systemd \
  dbus \
  polkit \
  udiskie

# Programming Language Servers (for development)
print_status "Installing language servers..."
sudo pacman -S --needed --noconfirm \
  lua-language-server \
  gopls

# AUR Packages
print_status "Installing essential AUR packages..."
yay -S --needed --noconfirm \
  spotify \
  bitwarden-bin

# Enable essential services
print_status "Enabling essential services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
sudo systemctl enable reflector.timer

# Create essential directories
print_status "Creating essential directories..."
mkdir -p ~/.local/bin
mkdir -p ~/Pictures/Screenshots

# Changing shell
sudo chsh -s $(which zsh)

# Final setup recommendations
print_success "Essential packages installation completed!"
echo
print_status "Post-installation recommendations:"
echo "1. Reboot your system to ensure all services start properly"
echo "2. Set up your Git configuration: git config --global user.name/user.email"
echo "3. Install additional AUR packages as needed"
echo "4. Customize your Hyprland, Waybar, and other configurations"
echo "5. Update your system: sudo pacman -Syu"
echo "6. Source your Rust environment: source ~/.cargo/env"

print_warning "Note: This script installs the core packages. You may want to install additional packages based on your specific needs."

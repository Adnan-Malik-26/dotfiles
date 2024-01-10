sudo pacman -Syu adobe-source-code-pro-fonts adwaita-cursors adwaita-icon-theme alsa archlinux-keyring autoconf automake awesome-terminal-fonts bat binutils bluez cmake gcc git discord duf gping fish electron python313 extra-cmake-modules fakeroot feh ffmpeg fontconfig gawk gnome-calculator gnome-tweaks go grub i3-wm imagemagick man-db neofetch neovim sddm networkmanager zsh alacritty base-devel bandwhich blueman coreutils diff-so-fancy curl tldr thunar dunst figlet gpaste lsd lxappearance make mesa ninja npm okular picom polybar qbittorrent virt-manager qemu ranger rofi ttf-jetbrains-mono ttf-firacode-nerd bat starship ttf-ms-fonts noto-fonts-emoji libreoffice ventoy openrgb obs-studio swayidle github-cli swayidle xorg-fonts-100dpi xorg-fonts-75dpi mako meson nerd-fonts-git openssh perl polkit ppsspp telegram-desktop themix-full-git

mkdir ~/Clones/
cd Clones 
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si 

yay -S thorium-bin wayland-screenshot swaylock-effects-git wlogout light swww-git cava cloudflare-warp-bin bibata-cursor-theme bibata-extra-cursor-theme betterdiscord-installer 


curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


# XDG
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
mkdir -p "$XDG_DATA_HOME/zsh"

# Environment Variables
export EDITOR="$HOME/.local/share/bob/nvim-bin/nvim"
export MANPAGER='nvim +Man!'
export VENV_HOME="$HOME/.virtualenvs"
export PNPM_HOME="$HOME/.local/share/pnpm"
export FONTCONFIG_FILE="$HOME/.config/fontconfig/fonts.conf"
export FREETYPE_PROPERTIES="truetype:interpreter-version=40"
export NVM_DIR="$HOME/.nvm"
export GOPATH="$HOME/.local/share/go"
export GOBIN="$HOME/.local/bin"

# PATH
path=(
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/.npm-global/bin
  $HOME/.deno/bin
  $PNPM_HOME
  /usr/local/go/bin
  /usr/local/bin
  /usr/sbin
  /usr/bin
  $HOME/.local/share/bob/nvim-bin
  $GOBIN
  $path
)
typeset -U path
path=($^path(N-/))

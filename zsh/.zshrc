# ============================================================================
# ZSH Configuration
# ============================================================================
# ----------------------------------------------------------------------------
# Zinit Plugin Manager
# ----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Install Zinit if not present
if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ----------------------------------------------------------------------------
# Plugins (with async loading)
# ----------------------------------------------------------------------------
# Load immediately (critical for prompt)
zinit light zsh-users/zsh-completions

# Load with delay (non-critical)
zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zsh-users/zsh-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
        Aloxaf/fzf-tab \
        hlissner/zsh-autopair

# Oh-My-Zsh Snippets (async)
zinit wait lucid for \
    OMZP::sudo \
    OMZP::archlinux \
    OMZP::kubectl \
    OMZP::kubectx \
    OMZP::command-not-found

# ----------------------------------------------------------------------------
# Completion System with Caching
# ----------------------------------------------------------------------------
autoload -Uz compinit

# Cache completions for 24 hours
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

fpath+=~/.zfunc

# ----------------------------------------------------------------------------
# Prompt
# ----------------------------------------------------------------------------
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/base.toml)"

# ----------------------------------------------------------------------------
# Shell Options
# ----------------------------------------------------------------------------
# Navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
set -o vi

# History
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

# ----------------------------------------------------------------------------
# History Configuration
# ----------------------------------------------------------------------------
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

# ----------------------------------------------------------------------------
# Completion Styling
# ----------------------------------------------------------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Enable completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# ----------------------------------------------------------------------------
# Environment Variables
# ----------------------------------------------------------------------------
export TERM=kitty
export EDITOR=/home/adnanmalik/.config/nvs/versions/current/bin/nvim
export MANPAGER='nvim +Man!'
export VENV_HOME="$HOME/.virtualenvs"
export PNPM_HOME="$HOME/.local/share/pnpm"
export FONTCONFIG_FILE="$HOME/.config/fontconfig/fonts.conf"
export FREETYPE_PROPERTIES="truetype:interpreter-version=40"

export NVM_DIR="$HOME/.nvm"

# ----------------------------------------------------------------------------
# PATH Configuration
# ----------------------------------------------------------------------------
path=(
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/.spicetify
  $HOME/scripts
  $HOME/.npm-global/bin
  $HOME/.config/emacs/bin
  $HOME/.pixi/bin
  $HOME/Downloads/gitthings/swww/target/release
  $HOME/Downloads/gitthings/eww/target/release
  $HOME/.deno/bin
  $PNPM_HOME
  /home/linuxbrew/.linuxbrew/bin
  /usr/local/go/bin
  /usr/local/bin
  /usr/sbin
  /usr/bin
  $path
)

# Remove duplicate entries
typeset -U path

# ----------------------------------------------------------------------------
# FZF Configuration
# ----------------------------------------------------------------------------
export FZF_DEFAULT_OPTS=" \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

eval "$(fzf --zsh)"

# ----------------------------------------------------------------------------
# Tool Integrations
# ----------------------------------------------------------------------------
eval "$(zoxide init --cmd z zsh)"

[[ -f /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh
[[ -f "$HOME/.deno/env" ]] && . "$HOME/.deno/env"
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

nvm() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

node() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  node "$@"
}

npm() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  npm "$@"
}

npx() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
  npx "$@"
}

# ----------------------------------------------------------------------------
# Aliases - General
# ----------------------------------------------------------------------------
alias c='clear'
alias cl='clear'
alias celar='clear'
alias tm='tmux -u'
alias tmux='tmux new-session -A -s playground'
alias img='imv'
alias impressive='impressive -t None'
alias fman="compgen -c | fzf | xargs man"

# Quit aliases (vim-style)
alias :q='exit'
alias qq='exit'
alias :wq='exit'
alias :qw='exit'

# Config shortcuts
alias sss='source ~/.zshrc'
alias b='nvim ~/.zshrc'

# Utilities
alias uptime='uptime -p'
alias btop='btop --force-utf'
alias y='yazi'
alias meat='grep "^\s*[^#;]"'
alias giveip="ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"

# ----------------------------------------------------------------------------
# Aliases - Navigation
# ----------------------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Clear and list combinations
alias rls='clear && ls'
alias cls='clear && ls'
alias cla='clear && ls -a'
alias cv='clear && fastfetch && ls'

# ----------------------------------------------------------------------------
# Aliases - File Operations
# ----------------------------------------------------------------------------
alias cp='cp -vi'
alias mv='mv -vi'
alias mdkir='mkdir'

alias 'ls'='ls --color=auto --group-directories-first -N'
alias 'la'='ls --color=auto --group-directories-first -Na'
alias 'll'='ls --color=auto --group-directories-first -Nl'

# ----------------------------------------------------------------------------
# Aliases - Neovim
# ----------------------------------------------------------------------------
alias vi='nvim'
alias v='nvim'
alias vim='nvim'
alias nv='nvim'
alias nvf="nvim -c ':lua Snacks.picker.files()'"

# ----------------------------------------------------------------------------
# Aliases - Git & LazyGit
# ----------------------------------------------------------------------------
alias add='git add .'
alias branch='git branch'
alias clone='git clone'
alias commit='git commit -m'
alias fetch='git fetch'
alias push='git push'
alias psuh='git push'
alias ginit='git add . && git commit -m "Initial Commit" && git push'
alias stat='git status'
alias tag='git tag'
alias newtag='git tag -a'
alias lg='lazygit'
alias gpush='git add . && git commit -m "$(date "+%d:%m:%y %H:%M")" && git push'


# ----------------------------------------------------------------------------
# Aliases - Package Management (Yay)
# ----------------------------------------------------------------------------
alias up='yay'
alias u='yay -Syu --noconfirm'
alias s='yay -Ss'
alias i='yay -S --noconfirm'
alias rr='yay -R --noconfirm'

# ----------------------------------------------------------------------------
# Aliases - Development Tools
# ----------------------------------------------------------------------------
# Go
alias gr='go run .'
# C++
alias ccc='c++'
alias run='c++ main.cpp && ./a.out'

alias startServer='java -Xmx1024M -Xms1024M -jar server.jar nogui'

# Hardhat
alias hh='npx hardhat'
alias hc='npx hardhat compile'
alias hx='npx hardhat compile'

# ----------------------------------------------------------------------------
# Aliases - System Control
# ----------------------------------------------------------------------------
alias snn='shutdown now'
alias rnn='reboot'

# ----------------------------------------------------------------------------
# Aliases - Note Taking
# ----------------------------------------------------------------------------
alias 'oo'="cd ~/Notes/ && nvim -c ':Telescope find_files'"

# ----------------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------------
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

# Make directory and cd into it
mkcd() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi
  mkdir -p "$1" && cd "$1"
}

# Extract archives
ex() {
  if [[ ! -f "$1" ]]; then
    echo "'$1' is not a valid file!"
    return 1
  fi

  case "$1" in
    *.tar.bz2)  tar xvjf "$1"    ;;
    *.tar.gz)   tar xvzf "$1"    ;;
    *.tar.xz)   tar -xf "$1"     ;;
    *.bz2)      bunzip2 "$1"     ;;
    *.rar)      unrar x "$1"     ;;
    *.gz)       gunzip "$1"      ;;
    *.tar)      tar xvf "$1"     ;;
    *.tbz2)     tar xvjf "$1"    ;;
    *.tgz)      tar xvzf "$1"    ;;
    *.zip)      unzip "$1"       ;;
    *.Z)        uncompress "$1"  ;;
    *.7z)       7z x "$1"        ;;
    *)          echo "don't know how to extract '$1'..." ;;
  esac
}

gcommit() {
  local types=("feat" "fix" "docs" "style" "refactor" "perf" "test" "build" "ci" "chore" "revert")
  local type scope message breaking
  
  echo "Select commit type:"
  select type in "${types[@]}"; do
    if [[ -n "$type" ]]; then
      break
    fi
  done
  echo -n "Enter scope (optional, press Enter to skip): "
  read scope
  echo -n "Enter commit message: "
  read message
  echo -n "Is this a breaking change? (y/N): "
  read breaking
  local commit_msg="$type"
  [[ -n "$scope" ]] && commit_msg="${commit_msg}(${scope})"
  if [[ "$breaking" =~ ^[Yy]$ ]]; then
    commit_msg="${commit_msg}!: ${message}"
    echo -n "Enter breaking change description: "
    read breaking_desc
    git commit -m "$commit_msg" -m "BREAKING CHANGE: $breaking_desc"
  else
    commit_msg="${commit_msg}: ${message}"
    git commit -m "$commit_msg"
  fi
  echo "Committed: $commit_msg"
}

# Quick conventional commits (shortcuts)
gfeat() { git commit -m "feat: $*"; }
gfix() { git commit -m "fix: $*"; }
gdocs() { git commit -m "docs: $*"; }
gstyle() { git commit -m "style: $*"; }
grefactor() { git commit -m "refactor: $*"; }
gtest() { git commit -m "test: $*"; }
gchore() { git commit -m "chore: $*"; }

[[ -d $VENV_HOME ]] || mkdir -p "$VENV_HOME"

lsvenv() {
  ls -1 "$VENV_HOME"
}

venv() {
  if [[ $# -eq 0 ]]; then
    echo "Please provide venv name"
    return 1
  fi
  source "$VENV_HOME/$1/bin/activate"
}

mkvenv() {
  if [[ $# -eq 0 ]]; then
    echo "Please provide venv name"
    return 1
  fi
  python3 -m venv "$VENV_HOME/$1"
}

rmvenv() {
  if [[ $# -eq 0 ]]; then
    echo "Please provide venv name"
    return 1
  fi
  rm -rf "$VENV_HOME/$1"
}

# Sesh session manager
sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect "$session"
  }
}

zle -N sesh-sessions

# ----------------------------------------------------------------------------
# Compile .zshrc for faster loading
# ----------------------------------------------------------------------------
# This runs in the background to not slow down shell startup
compile_zshrc() {
  local zshrc="${ZDOTDIR:-$HOME}/.zshrc"
  local zwc="${zshrc}.zwc"
  
  # Compile .zshrc if it's newer than the compiled version
  if [[ ! -f "$zwc" || "$zshrc" -nt "$zwc" ]]; then
    zcompile "$zshrc" 2>/dev/null || rm -f "$zwc"
  fi
}

# Run compilation in background
compile_zshrc &!

# ----------------------------------------------------------------------------
# End of Configuration
# ----------------------------------------------------------------------------

export PATH=$PATH:/home/adnanmalik/.spicetify

fpath+=~/.zfunc; autoload -Uz compinit; compinit

fpath+=~/.local/share/zsh/completions
autoload -Uz compinit
compinit
export BW_SESSION="s4OJbhCGuvG4K/YJWkFAjjHVG/4mC8nGhg1wF7hPUyx1c0gVDBWqS2+JP1FInryLCXPszD5PCwn0FfJdcuoKKA=="

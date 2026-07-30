# ============================================================================
# ZSH Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# Zinit Plugin Manager
# ----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ----------------------------------------------------------------------------
# Plugins (async / turbo loading)
# ----------------------------------------------------------------------------
# Load immediately (needed synchronously for completion generation)
zinit light zsh-users/zsh-completions

# Turbo group — deferred to after first prompt.
# NOTE: compinit is called explicitly, once, below — not via zicompinit here,
# to avoid the triple-compinit cost the old config paid on every start.
zinit wait lucid for \
        zsh-users/zsh-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
        Aloxaf/fzf-tab \
        hlissner/zsh-autopair \
        jeffreytse/zsh-vi-mode

zinit wait lucid for \
    OMZP::sudo \
    OMZP::archlinux \
    OMZP::kubectl \
    OMZP::kubectx \
    OMZP::command-not-found

# zsh-vi-mode resets keymaps on init, which silently kills any bindkey
# calls you made earlier in the file (e.g. magic-space below). Hook custom
# bindkeys here so they survive vi-mode's reset — this function is called
# by the plugin itself after it finishes initializing.
function zvm_after_init() {
  bindkey ' ' magic-space
}

# ----------------------------------------------------------------------------
# Completion Styling (must be set before compinit runs)
# ----------------------------------------------------------------------------
zstyle ':completion:*' matcher-list \
'm:{[:lower:]}={[:upper:]} r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*' max-errors 2
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# ----------------------------------------------------------------------------
# Completion System with Caching (single call — do NOT duplicate elsewhere)
# ----------------------------------------------------------------------------
fpath+=~/.zfunc
fpath+=~/.local/share/zsh/completions

autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ----------------------------------------------------------------------------
# Prompt
# ----------------------------------------------------------------------------
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/themes/monoknight.omp.json)"

# ----------------------------------------------------------------------------
# Shell Options
# ----------------------------------------------------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt LONG_LIST_JOBS
setopt NO_FLOW_CONTROL
setopt HIST_VERIFY

KEYTIMEOUT=1

# ----------------------------------------------------------------------------
# Keybinds
# ----------------------------------------------------------------------------
# (magic-space is (re)bound in zvm_after_init above, since vi-mode wipes it)

ZVM_CURSOR_STYLE_ENABLED=true
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
bindkey '^G' clear-screen

# ----------------------------------------------------------------------------
# History Configuration
# ----------------------------------------------------------------------------
HISTSIZE=5000
HISTFILE="$XDG_DATA_HOME/zsh/history"
SAVEHIST=$HISTSIZE
HISTDUP=erase

# ----------------------------------------------------------------------------
# Environment Variables
# ----------------------------------------------------------------------------
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
  $HOME/go/bin
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
typeset -U path

# ----------------------------------------------------------------------------
# FZF Configuration
# ----------------------------------------------------------------------------
export FZF_DEFAULT_OPTS=" \
--color=fg:#e6e6e6,header:#e8b4b4,info:#dac3dd,pointer:#eeeac9 \
--color=marker:#c3cadd,fg+:#ffffff,prompt:#f7dcc6,hl+:#c4d6c4 \
--color=selected-bg:#3a3a3a \
--multi"

export FZF_CTRL_R_OPTS="
--height=80%
--color=header:italic
--header='CTRL-Y: Copy command · CTRL-/: Toggle wrap · CTRL-R: Toggle relevance'
--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
"

export FZF_CTRL_T_OPTS="
--walker-skip .git,node_modules,target
--preview 'bat --style=numbers --color=always {}'
--height=80%
--bind 'ctrl-/:change-preview-window(down|hidden|)'
--header='CTRL-/: Toggle preview'
"

export FZF_ALT_C_OPTS="
--walker-skip .git,node_modules,target
--preview 'eza --tree --level=2 --icons {}'
--height=80%
--bind 'ctrl-/:change-preview-window(down|hidden|)'
--header='CTRL-/: Toggle preview'
"
eval "$(fzf --zsh)"

# ----------------------------------------------------------------------------
# Tool Integrations
# ----------------------------------------------------------------------------
eval "$(zoxide init --cmd z zsh)"

[[ -f "$HOME/.deno/env" ]] && . "$HOME/.deno/env"
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# ---- nvm: truly lazy (this was the biggest startup cost in the old config) --
# The old file sourced /usr/share/nvm/init-nvm.sh eagerly TWICE — once
# directly, once again at the bottom AFTER these wrapper functions, which
# silently overwrote the lazy stubs with the real (slow) nvm functions.
# Fix: never source init-nvm.sh at shell start. First call to any of these
# does the real load, once, on demand.
_nvm_lazy_load() {
  unset -f nvm node npm npx
  [[ -s /usr/share/nvm/init-nvm.sh ]] && \. /usr/share/nvm/init-nvm.sh
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
}
nvm()  { _nvm_lazy_load; nvm "$@"; }
node() { _nvm_lazy_load; node "$@"; }
npm()  { _nvm_lazy_load; npm "$@"; }
npx()  { _nvm_lazy_load; npx "$@"; }

# ----------------------------------------------------------------------------
# Aliases - General
# ----------------------------------------------------------------------------
alias c='clear'
alias cl='clear'
alias cll='clear && fastfetch && ls'
alias celar='clear'
alias tm='tmux -u'
alias tmux='tmux new-session -A -s playground'
alias img='imv'
alias impressive='impressive -t None'
alias fman="compgen -c | fzf | xargs man"

alias :q='exit'
alias qq='exit'
alias :wq='exit'
alias :qw='exit'

alias sss='source ~/.zshrc'
alias b='nvim ~/.zshrc'

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

alias ls='eza --icons --group-directories-first --no-quotes'
alias la='eza -a --icons --group-directories-first --no-quotes'
alias ll='eza -lah --icons --group-directories-first --git --header --no-quotes'
alias lt='eza --tree --level=2 --icons'
# renamed from `lg` (was silently shadowed by the lazygit alias below anyway)
alias lsg='eza -lah --git --icons --header'

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
alias gr='go run .'
alias ccc='c++'
alias run='c++ main.cpp && ./a.out'

alias startServer='java -Xmx1024M -Xms1024M -jar server.jar nogui'
alias startFabric='java -Xmx2G -jar fabric-server-mc.26.2-loader.0.19.3-launcher.1.1.1.jar nogui'

alias hh='npx hardhat'
alias hc='npx hardhat compile'
alias hx='npx hardhat compile'

# ----------------------------------------------------------------------------
# Aliases - System Control
# ----------------------------------------------------------------------------
alias snn='shutdown now'
alias rnn='reboot'
alias ssp='systemctl suspend'

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
    sesh connect "$session"
  }
}
zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

mkcd() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi
  mkdir -p "$1" && cd "$1"
}

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

# ----------------------------------------------------------------------------
# Compile .zshrc for faster loading (background zcompile)
# ----------------------------------------------------------------------------
compile_zshrc() {
  local zshrc="${ZDOTDIR:-$HOME}/.zshrc"
  local zwc="${zshrc}.zwc"
  if [[ ! -f "$zwc" || "$zshrc" -nt "$zwc" ]]; then
    zcompile "$zshrc" 2>/dev/null || rm -f "$zwc"
  fi
}
compile_zshrc &!

# ----------------------------------------------------------------------------
# End of Configuration
# ----------------------------------------------------------------------------
export PATH=$PATH:/home/adnanmalik/.spicetify

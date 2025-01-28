# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
fastfetch
# confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
# zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/base.toml)"
# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias vim='nvim'
alias c='clear'
alias 'celar'='clear'

# CD aliases
alias '..'='cd ..'
alias '...'='cd ../..'
alias '....'='cd ../../..'
#Git
alias add='git add .'
alias branch='git branch'
alias clone='git clone'
alias commit='git commit -m'
alias fetch='git fetch'
alias push='git push'
alias psuh='git push'
alias stat='git status'
alias tag='git tag'
alias newtag='git tag -a'
alias lg='lazygit'

#y to yazi
alias 'y'='yazi'

#Quitting Terminal
alias ':q'="exit"
alias ':qw'='exit'
alias ':wq'='exit'

#Neovim Alias
alias 'vi'='nvim'
alias 'vim'='nvim'
alias 'nv'='nvim'

#Alternatives
alias df='duf'
alias 'cat'='bat'
alias 'ping'='gping -c blue'

#Opening Configs
alias 'i3c'='nvim ~/.config/i3/config '
alias 'plc'='nvim ~/.config/polybar/config.ini'
alias 'nfc'='nvim ~/.config/neofetch/config.conf'
alias 'alc'='nvim ~/.config/alacritty/alacritty.yml'
alias 'ts'='tmux source ~/.config/tmux/tmux.conf'
alias 'tmc'='nvim ~/.config/tmux/tmux.conf'


#List Aliases
alias 'ls'='eza --icons --group-directories-first'
alias 'la'='eza -a --icons --group-directories-first'
alias 'll'='eza -al --icons --group-directories-first --no-user --no-time --created'
alias 'l'='eza -al --icons --group-directories-first --no-user --no-time --created'

#Adding Flags
alias df='df -h'
alias free='free -m'

#zshrc
alias 's'='source ~/.zshrc'
alias 'b'='nvim ~/.zshrc'

#Adding Verbose
alias 'cp'='cp -v'
alias 'rm'='rm -v'
alias 'mv'='mv -v'
alias 'cl'='clear'
alias 'rls'='clear&&ls'
alias 'cv'='clear&&neofetch&&ls'
alias 'cls'='clear&&ls'
alias 'cla'='clear&&ls -a'

# Meat of the File
alias meat='grep "^\s*[^#;]"'

#Gives Ip address
alias 'giveip'="ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"


#Update and Upgrade aliases
alias 'up'='yay'
alias 'ff'='fastfetch'

# Shutdown and Reboot
alias 'ssn'='shutdown now'
alias 'snn'='shutdown now'
alias 'rnn'='reboot'

#C++ Alias
alias 'ccc'='c++'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"



###PATH
export PATH=$PATH:$HOME/.local/bin/
export PATH=$PATH:/usr/bin
export PATH=$PATH:$HOME/.spicetify
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/share/bob/nvim-bin
export PATH=$PATH:$HOME/.local/share/bob/nightly/nvim-linux64/bin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:$HOME/scripts/
export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin
export PATH=$PATH:$HOMEclones/swww/target
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.config/emacs/bin
export MANPAGER='nvim +Man!'

export BAT_THEME='Catppuccin Frappe'

eval $(thefuck --alias)
eval $(thefuck --alias fk)

export FZF_DEFAULT_OPTS=" \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

# Functions
ex() {
  if [ -f $1 ]; then
    case $1 in
    *.tar.bz2) tar xvjf $1 ;;
    *.tar.gz) tar xvzf $1 ;;
    *.bz2) bunzip2 $1 ;;
    *.rar) unrar x $1 ;;
    *.gz) gunzip $1 ;;
    *.tar) tar xvf $1 ;;
    *.tbz2) tar xvjf $1 ;;
    *.tgz) tar xvzf $1 ;;
    *.zip) unzip $1 ;;
    *.Z) uncompress $1 ;;
    *.7z) 7z x $1 ;;
    *.tar.xz) tar -xf $1 ;;
    *) echo "don't know how to extract '$1'..." ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}


export PATH=$PATH:/home/adnanmalik/.spicetify


. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

# Completion Styling
zstyle ':completion:*' matcher-list \
'm:{[:lower:]}={[:upper:]} r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*' max-errors 2
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Completion Init
fpath+=~/.zfunc
fpath+=~/.local/share/zsh/completions

autoload -Uz compinit

local zcd="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -f "$zcd" || -n "$zcd"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

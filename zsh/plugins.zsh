# Zinit Bootstrap
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Sync-Loaded Plugins
zinit light zsh-users/zsh-completions

# Turbo-Loaded Plugins
zinit wait lucid for \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
        Aloxaf/fzf-tab \
        hlissner/zsh-autopair \
        jeffreytse/zsh-vi-mode \
        zsh-users/zsh-history-substring-search

# Oh My Zsh Plugins
zinit wait lucid for \
    OMZP::sudo \
    OMZP::archlinux \
    OMZP::kubectl \
    OMZP::kubectx \
    OMZP::command-not-found

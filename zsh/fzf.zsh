# FZF Options
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

# FZF Shell Integration
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  source /opt/homebrew/opt/fzf/shell/completion.zsh
elif [[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]]; then
  source /usr/local/opt/fzf/shell/key-bindings.zsh
  source /usr/local/opt/fzf/shell/completion.zsh
elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
elif [[ -f "$HOME/.fzf/shell/key-bindings.zsh" ]]; then
  source "$HOME/.fzf/shell/key-bindings.zsh"
  source "$HOME/.fzf/shell/completion.zsh"
fi

# Vi Mode Config
ZVM_CURSOR_STYLE_ENABLED=true
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
KEYTIMEOUT=1

# Post Vi-Mode Init Keybinds
function zvm_after_init() {
  bindkey ' ' magic-space
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word
  bindkey '^F' _fzf_file_no_hidden
}

# General Keybinds
bindkey '^G' clear-screen

# Sesh Session Picker
zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

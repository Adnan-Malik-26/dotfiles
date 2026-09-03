# Zoxide
source $HOME/dotfiles/zsh/zoxide.zsh

# Deno / Local Bin Env
if [[ -f "$HOME/.deno/env" ]]; then
  . "$HOME/.deno/env"
fi
if [[ -f "$HOME/.local/bin/env" ]]; then
  . "$HOME/.local/bin/env"
fi

# NVM Lazy Load
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

# Sesh Session Picker
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

# Directory Creation
mkcd() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi
  mkdir -p "$1" && cd "$1"
}

# Universal Archive Extractor
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

# Conventional Commit Wizard
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

# Conventional Commit Shortcuts
gfeat() { git commit -m "feat: $*"; }
gfix() { git commit -m "fix: $*"; }
gdocs() { git commit -m "docs: $*"; }
gstyle() { git commit -m "style: $*"; }
grefactor() { git commit -m "refactor: $*"; }
gtest() { git commit -m "test: $*"; }
gchore() { git commit -m "chore: $*"; }

# Python Virtualenv Management
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

# FZF File Picker (No Hidden)
_fzf_file_no_hidden() {
  local file
  file=$(fd --type f --hidden --exclude .git --exclude node_modules 2>/dev/null \
         | fzf --preview 'bat --style=numbers --color=always {}' --height=80%) \
    || { zle redisplay; return; }
  [[ -n "$file" ]] && LBUFFER+="${file} "
  zle reset-prompt
}
zle -N _fzf_file_no_hidden

# Compile .zshrc For Faster Loading
compile_zshrc() {
  local zshrc="${ZDOTDIR:-$HOME}/.zshrc"
  local zwc="${zshrc}.zwc"
  if [[ ! -f "$zwc" || "$zshrc" -nt "$zwc" ]]; then
    zcompile "$zshrc" 2>/dev/null || rm -f "$zwc"
  fi
}

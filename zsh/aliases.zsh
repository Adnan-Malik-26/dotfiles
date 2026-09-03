# General
alias c='clear'
alias cl='clear'
alias cll='clear && fastfetch && ls'
alias celar='clear'
alias tm='tmux -u'
alias img='imv'
alias impressive='impressive -t None'
alias fman="compgen -c | fzf | xargs man"

alias :q='exit'
alias qq='exit'
alias :wq='exit'
alias :qw='exit'

alias sss='compile_zshrc && source ~/.zshrc'
alias b='nvim $HOME/dotfiles/zsh/.zshrc'

alias uptime='uptime -p'
alias btop='btop --force-utf'
alias y='yazi'
alias meat='grep "^\s*[^#;]"'
alias giveip="ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias rls='clear && ls'
alias cls='clear && ls'
alias cla='clear && ls -a'
alias cv='clear && fastfetch && ls'

# File Operations
alias cp='cp -vi'
alias mv='mv -vi'
alias mdkir='mkdir'

alias ls='eza --icons --group-directories-first --no-quotes'
alias la='eza -a --icons --group-directories-first --no-quotes'
alias ll='eza -lah --icons --group-directories-first --git --header --no-quotes'
alias lt='eza --tree --level=2 --icons'
alias lsg='eza -lah --git --icons --header'

# Neovim
alias vi='nvim'
alias nv='nvim'
alias nvf="nvim -c ':lua Snacks.picker.files()'"

# Git & LazyGit
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

# Package Management (Yay)
alias up='yay'
alias u='yay -Syu --noconfirm'
alias s='yay -Ss'
alias i='yay -S --noconfirm'
alias rr='yay -R --noconfirm'

# Development Tools
alias gr='go run .'
alias ccc='c++'
alias run='c++ main.cpp && ./a.out'

alias startServer='java -Xmx1024M -Xms1024M -jar server.jar nogui'
alias startFabric='java -Xmx2G -jar fabric-server-mc.26.2-loader.0.19.3-launcher.1.1.1.jar nogui'

alias hh='npx hardhat'
alias hc='npx hardhat compile'
alias hx='npx hardhat compile'

# System Control
alias snn='shutdown now'
alias rnn='reboot'
alias ssp='systemctl suspend'

# Note Taking
alias 'oo'="cd ~/Notes/ && nvim -c ':Telescope find_files'"

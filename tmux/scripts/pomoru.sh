#!/bin/sh

if tmux has-session 2>/dev/null; then
    current=$(tmux display-message -p '#{window_name}')

    if tmux list-windows -F '#{window_name}' | grep -qx 'pomoru'; then
        if [ "$current" = "pomoru" ]; then
            tmux last-window
        else
            tmux select-window -t pomoru
        fi
    else
        tmux new-window -d -n pomoru pomoru
        tmux select-window -t pomoru
    fi
fi

autoload -Uz add-zsh-hook

function rename_tmux_window() {
    if [ $(echo $TERM | grep 'screen') ]; then
        tmux rename-window $(pwd)
    fi
}

# add-zsh-hook precmd rename_tmux_window

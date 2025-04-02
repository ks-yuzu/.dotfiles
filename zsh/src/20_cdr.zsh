autoload -Uz is-at-least

if is-at-least 4.3.11; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs

    # cdr の設定
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/shell/chpwd-recent-dirs"
    zstyle ':chpwd:*' recent-dirs-pushd true


    function cdr-fzf {
      local dir=$(
        cdr -l \
          | fzf --nth 2.. \
                --accept-nth 2 \
                --preview 'ls -l --almost-all --si --time-style=long-iso $(sed "s|^~|$HOME|" <<<{2..})' \
                --preview-window=bottom \
      )
      if [ -n "$dir" ]; then
        BUFFER="cd ${dir}"
        zle accept-line
      fi
    }
    zle -N cdr-fzf && bindkey '^v' $_
fi

# cd -[tab]で過去のディレクトリに移動
setopt auto_pushd

#### [ completion ]
# auto-complete
autoload -Uz compinit && compinit -u


setopt extended_glob                         # use wildcard
zstyle ':completion:*:default' menu select=2 # cursor select completion

setopt auto_param_keys                       # completion of a pair of () {} etc.
setopt auto_param_slash

setopt correct                               # spell check
setopt brace_ccl                             # {a-c} -> a b c


#### [ key ]
bindkey -e                                   # emacs like
bindkey "\e[Z" reverse-menu-complete         # enable Shift-Tab

setopt ignore_eof                            # Ctrl+Dでzshを終了しない

# CapsLock -> ctrl
if (( ${+commands[setxkbmap]} )); then
    if [[ "$(uname)" != 'Darwin' ]]; then
        setxkbmap -option ctrl:nocaps
    fi
fi

# xmodmap
[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap

#### [ color ]
# mac でも dircolors を使うために coreutils (GNU ls) を有効にする
if [ "$(uname)" = 'Darwin' ]; then
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
fi

eval $(dircolors ~/.dotfiles/zsh/dircolors.256dark) # ls color

# completion coloring
[ -n "$LS_COLORS" ] && zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}


#### [ history ]
HISTFILE=~/.zsh_histfile
HISTSIZE=1000000
SAVEHIST=1000000

# Screenでのコマンド共有用
setopt inc_append_history       # シェルを横断して.zsh_historyに記録
setopt share_history            # ヒストリを共有

setopt hist_ignore_dups         # 直前と同じコマンドをヒストリに追加しない
setopt hist_ignore_all_dups     # ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_space        # コマンドがスペースで始まる場合、コマンド履歴に追加しない


#### [ others ]
setopt interactive_comments

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

# emacs shell mode
if [ -n "$INSIDE_EMACS" ]; then
    export EDITOR=emacsclient
    unset zle_bracketed_paste  # This line
fi


#### [ 分割設定ファイル ]

# for i in `find \`dirname $0\` -maxdepth 1 -mindepth 1 | grep '\.zsh$' | grep -v 'init.zsh'`
# do
#     source $i
# done

# for i in `find \`dirname $0\`/completion -maxdepth 1 -mindepth 1 | grep '\.zsh$'`
# do
#     source $i
# done


# tmp
source ${HOME}/.zprofile

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
setopt extended_history         # コマンドの実行時刻を記録

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
# [[ -f ${HOME}/.zprofile ]] && source ${HOME}/.zprofile

## plenv
export PATH="$HOME/.plenv/bin:$PATH"

if [ -x "`which plenv 2> /dev/null`" ]; then
  eval "$(plenv init -)"
  export PLENV_VERSION=$(plenv version | awk '{print $1}')
  # export PERL_CPANM_OPT="--local-lib=${PERL_LOCAL_LIB}"
  # export PATH=${PLENV_ROOT}/bin:$PATH
  # export PERL5LIB=${PLENV_ROOT}/versions/${PLENV_VERSION}/lib/perl5:$PERL5LIB
fi


## node
export NODE_PATH=`npm -g root`

if [ -d "$HOME/.nodebrew/node/v13.7.0/bin/" ]; then
    export "PATH=$PATH:$HOME/.nodebrew/node/v13.7.0/bin"
fi


## ruby
eval "$(rbenv init -)"


## cabal
# export PATH=$HOME/.cabal/bin:$PATH

## go
export GOPATH=~/.go
export PATH=$GOPATH/bin:$PATH


## others
# export PATH=$PATH:$HOME/.local/lib/python2.7/site-packages/powerline
# export PATH=$PATH:/opt/ibm/ILOG/CPLEX_Studio1261/cplex/bin/x86-64_linux
export PATH=$HOME/bin:$PATH
export PATH=$HOME/opt:$PATH
export PATH=$HOME/.cargo/bin:$PATH

autoload -Uz add-zsh-hook

## tmux info disp
function disp-tmux-info()
{
    [[ $TERM =~ 'screen' ]] || return

    local NUM_SESSIONS=$(tmux list-sessions | wc -l)
    local NUM_WINDOWS=$( tmux list-windows  | wc -l)

    local CURR_SESSION_ID=$(tmux display -p '#S')
    local CURR_WINDOW_ID=$( tmux display -p '#I')

    local CURR_SESSION_NUM=$(tmux ls  | grep -n "^$CURR_SESSION_ID" | perl -ne 'print /^(\d+)/')
    local CURR_WINDOW_NUM=$( tmux lsw | grep -n "^$CURR_WINDOW_ID"  | perl -ne 'print /^(\d+)/')

    echo -n "W $CURR_WINDOW_NUM/$NUM_WINDOWS (WID:$CURR_WINDOW_ID), S $CURR_SESSION_NUM/$NUM_SESSIONS (SID:$CURR_SESSION_ID)"
}

function disp-tmux-info-mini()
{
    [[ $TERM =~ 'screen' ]] || return

    local NUM_SESSIONS=$(tmux list-sessions | wc -l)
    local NUM_WINDOWS=$( tmux list-windows  | wc -l)

    local CURR_SESSION_ID=$(tmux display -p '#S')
    local CURR_WINDOW_ID=$( tmux display -p '#I')

    local CURR_SESSION_NUM=$(tmux ls  | grep -n "^$CURR_SESSION_ID" | perl -ne 'print /^(\d+)/')
    local CURR_WINDOW_NUM=$( tmux lsw | grep -n "^$CURR_WINDOW_ID"  | perl -ne 'print /^(\d+)/')

    echo -n "W:$CURR_WINDOW_NUM/$NUM_WINDOWS S:$CURR_SESSION_NUM/$NUM_SESSIONS"
}

function disp-tmux-info-for-prompt()
{
    [[ $TERM =~ 'screen' ]] || return
    echo -n "[" $(disp-tmux-info-mini) "] "
}

function get-kube-cluster-info() {
    local kube_context=$(kubectl config current-context)
    if [[ "$_KUBE_CONTEXT" != "$kube_context" ]]; then
        _KUBE_CONTEXT=$kube_context
    else
        echo $_K8S_CLUSTER_INFO
        return
    fi

    if [[ $_KUBE_CONTEXT =~ gke ]]; then
        # _K8S_CLUSTER_INFO=" \e[38;5;33mgke:\e[m$(echo $_KUBE_CONTEXT | cut -d_ -f4-)"
        _K8S_CLUSTER_INFO=" \e[38;5;33mgke:\e[m$(echo $_KUBE_CONTEXT | cut -d_ -f2,4 --output-delimiter '/')"
        # _K8S_CLUSTER_INFO=" $(imgcat ~/.dotfiles/zsh/icons/gke-icon.png; echo -n -e "\033[2C")$(echo $_KUBE_CONTEXT | cut -d_ -f4-)"
    elif [[ $_KUBE_CONTEXT =~ aws ]]; then
        local product=$(get-aws-account-name-from-id $(echo $_KUBE_CONTEXT | cut -d: -f5))
        # sts token のアカウントとクラスタのアカウントが違っていれば色を変える
        if [[ ! -n "$STS_EXPIRATION_UNIXTIME" ]]; then
            :
        elif [[ "${STS_ALIAS_SHORT:-$AWS_PRODUCT}" = "$product" ]]; then
            product="%F{green}${product}%f"
        else
            product="%F{red}${product}%f"
        fi
        _K8S_CLUSTER_INFO=" \e[38;5;202meks:\e[m${product}/$(echo $_KUBE_CONTEXT | cut -d/ -f2)"
        # _K8S_CLUSTER_INFO=" $(imgcat ~/.dotfiles/zsh/icons/eks-icon.png; echo -n -e "\033[2C")${product}:$(echo $_KUBE_CONTEXT | cut -d/ -f2)"
    else
        _K8S_CLUSTER_INFO=''
    fi

    echo $_K8S_CLUSTER_INFO
}

function get-kube-ns-info() {
    # local NS=$(kubectl config view | grep namespace: | awk '{print $2}')
    local NS=$(kubectl config view | sed -n "/cluster: $(kubectl config current-context | perl -pe 's|/|\\/|g')/,/^-/p" | grep namespace | awk '{print $2}')
    if [[ -z "$NS" ]]; then
        return
    fi

    echo "($NS)"
}

function get-argocd-info() {
    ARGOCD_CONTEXT=$(argocd context | grep '^*' | awk '{print $2}' | cut -d. -f1)
    echo "\e[38;5;202margocd:\e[m${ARGOCD_CONTEXT}"
}

function _is_gcloud_config_updated() {
    local active_config config_default configurations
    local active_config_now config_default_now configurations_now
    local active_config_mtime config_default_mtime configurations_mtime mtime_fmt

    # if one of these files is modified, assume gcloud configuration is updated
    active_config="$HOME/.config/gcloud/active_config"
    config_default="$HOME/.config/gcloud/configurations/config_default"
    configurations="$HOME/.config/gcloud/configurations"

    zstyle -s ':zsh-gcloud-prompt:' mtime_fmt mtime_fmt

    active_config_now="$(stat $mtime_fmt $active_config 2>/dev/null)"
    config_default_now="$(stat $mtime_fmt $config_default 2>/dev/null)"
    configurations_now="$(stat $mtime_fmt $configurations 2>/dev/null)"

    zstyle -s ':zsh-gcloud-prompt:' active_config_mtime active_config_mtime
    zstyle -s ':zsh-gcloud-prompt:' config_default_mtime config_default_mtime
    zstyle -s ':zsh-gcloud-prompt:' configurations_mtime configurations_mtime

    if [[ "$active_config_mtime" != "$active_config_now" || "$config_default_mtime" != "$config_default_now" || "$configurations_mtime" != "$configurations_now" ]]; then
        zstyle ':zsh-gcloud-prompt:' active_config_mtime "$active_config_now"
        zstyle ':zsh-gcloud-prompt:' config_default_mtime "$config_default_now"
        zstyle ':zsh-gcloud-prompt:' configurations_mtime "$configurations_now"
        return 0
    else
        return 1
    fi
}

function _update_gcloud_context() {
    if _is_gcloud_config_updated; then
        # _GCLOUD_ACCOUNT="$(gcloud config get-value account 2>/dev/null)"
        _GCLOUD_PROJECT="$(gcloud config get-value project 2>/dev/null)"
    fi

    return 0
}


## prompt
function update-prompt()
{
    _update_gcloud_context

    if [ -n "$SSH_CONNECTION" ]; then
        host='%m'
    elif [ -f /.dockerenv ]; then
        host='docker'
    else
        host='local'
    fi

    local name="%F{green}%n@${host}%f"
    # local tmuxinfo=" %F{magenta}$(disp-tmux-info-for-prompt)%f"
    local tmuxinfo=""
    local kubeinfo="$(get-kube-cluster-info)$(get-kube-ns-info) "
    local argocdinfo="$(get-argocd-info) "
    local cdir="%F{yellow}%~%f "
    local endl=$'\n'
    local mark="%B%(?,%F{green},%F{red})%(!,#,>)%f%b "

    local face=''
    local info=''

    if [ -n "$AWS_PROFILE" ]; then
        info="$AWS_PROFILE"
    elif [ -z $STS_EXPIRATION_UNIXTIME ]; then
        face='(-ω-)zzz'
        info='(none)'
    else
        local lefttime="$(($STS_EXPIRATION_UNIXTIME - $(date +%s)))"

        if [ $lefttime -gt 0 ]; then
            face="('ω')"
            info="${STS_ALIAS_SHORT:-$AWS_PRODUCT}($lefttime)"
        else
            face='(>_<)'
            info="${STS_ALIAS_SHORT:-$AWS_PRODUCT}(%F{red}expired%f)"
        fi
    fi

    # local sts=" aws:${face}${info}"
    local sts=$' \e[38;5;202maws:\e[m'${info}
    # local sts=" $(imgcat ~/.dotfiles/zsh/icons/aws-icon.png; echo -n -e "\033[2C")${info}"
    local gcloud=$' \e[38;5;33mgcp:\e[m'${_GCLOUD_PROJECT:-(none)}
    # local gcloud=" $(imgcat ~/.dotfiles/zsh/icons/gcp-icon.png; echo -n -e "\033[2C")$_GCLOUD_PROJECT"

    PROMPT="${name}${tmuxinfo}${sts}${gcloud}${kubeinfo}${argocdinfo}${cdir}${endl}${mark}"
}
# add-zsh-hook precmd update-prompt




# rev prompt
autoload -Uz vcs_info
autoload -Uz colors
colors

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' max-exports 6 # max number of variables in format
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '%b@%r' '%c' '%u'
zstyle ':vcs_info:git:*' actionformats '%b@%r|%a' '%c' '%u'

setopt prompt_subst

function rprompt
{
    local st=$(git status 2> /dev/null)
    if [[ -z "$st" ]]; then return; fi

    local repo=$(vcs_echo)
    local dir=$(get-path-from-git-root)

    local current_branch=$(git branch | grep '^*' | cut -d' ' -f2 | grep -v '(HEAD')
    local upstream=$(git branch -vv | grep "^..$current_branch" | cut -d'[' -f2 | cut -d: -f1)
    local ahead_count=$(test ! -z "$current_branch" && git rev-list --count ${upstream}..${current_branch} 2>/dev/null | perl -ne '/(\d+)/ and $1 and print " +$1"')

    if [ ! -z $repo -o ! -z $dir ]; then
        echo "[$repo /$dir$ahead_count]"
    elif [ ! -z $repo -o -z $dir ]; then
        echo "[$repo /$ahead_count]"
    fi

}

function vcs_echo
{
    STY= LANG=en_US.UTF-8 vcs_info
    # local st=`git status 2> /dev/null`
    # if [[ -z "$st" ]]; then return; fi
    local branch="$vcs_info_msg_0_"
    local color
    if   [[ -n "$vcs_info_msg_1_" ]];                then color=${fg[yellow]} # staged
    elif [[ -n "$vcs_info_msg_2_" ]];                then color=${fg[red]}    # unstaged
    elif [[ -n $(echo "$st" | grep "^Untracked") ]]; then color=${fg[cyan]}   # untracked
    else                                                  color=${fg[green]}
    fi

    echo "%{$color%}$branch%{$reset_color%}" | sed -e s/@/"%F{white}@%f%{$color%}"/
}

function get-path-from-git-root
{
	git rev-parse --show-prefix 2> /dev/null
}

RPROMPT='$(rprompt)'

###################
#      alias
###################
alias ls='ls -F --show-control-chars --color=auto'
alias la='ls -a'
alias ll='ls -l --si --time-style=long-iso'
# alias ll='ls -l'
alias ltr='ls -l -tr'
alias lal='ls -l --almost-all --si --time-style=long-iso'
# alias lal='ls -al --color=auto'
alias laltr='ls -al -tr --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'

alias tmux='tmux -2'

#alias conky='conky -b NL'
#alias guake='guake &'

alias e='emacsclient -n'
alias ekill="emacsclient -e '(kill-emacs)'"
#alias ed='emacs --daemon'

alias gita='git add'
alias gitc='git commit -v'
alias gitcm='git commit -v -m'
alias gitst='git status'

if which xdg-open >/dev/null 2>&1 ; then # Linux
    alias op='xdg-open'
    alias open='xdg-open'
fi

alias octave='octave --no-gui'

alias gcc='gcc -Wall -Wextra -std=c11                               -Winline'
alias g++='g++ -Wall -Wextra -std=c++17 -Weffc++ -Wsuggest-override -Winline'

alias cdiff='colordiff'

alias dropbox='dropbox.py $(dropbox.py help | grep -P "^ " | peco | awk "{print \$1}")'


# ===== suffix alias =====
alias -s txt='cat'
alias -s html='google-chrome-stable'
alias -s pdf='evince'

# ===== global alias =====
# alias -g G='| grep'
# alias -g L='| less'
alias -g NL='>/dev/null 2>&1 &'

alias pm-suspend="echo \"[alias] 'pm-suspend' does not work well on Ubuntu14.04\""

alias sdedit="java -jar ~/bin/sdedit-4.2-beta7.jar $*"
alias plantuml="java -jar ~/bin/plantuml.jar $*"


function cd() { builtin cd $@ && ls --color; }
function pr-select { gh pr list| peco | awk '{print $1}' }

# alias ssh='perl -e '\''$args = join "_", (grep { $_ !~ /^\-/ } @ARGV); $ts = qx/date --iso-8601=seconds/; chomp $ts; exec "script ~/works/ssh-log/ssh-${ts}-${args}.log /usr/bin/ssh @ARGV"'\'''

function ssh() {
    tmux set automatic-rename off
    tmux rename-window "ssh $@"
    tmux set-window-option window-status-current-format "#[fg=colour255,bg=#00aa22,bold] #I: #([[ '#W' != 'zsh' && '#W' != 'reattach-to-user-namespace' ]] && echo #W || ([ #{pane_current_path} = $HOME ] && echo 'HOME' || basename #{pane_current_path} )) "
    # TODO: trap でステータスバー戻す

    # -t tmux -2
    perl -e '$args = join "_", (grep { $_ !~ /^\-/ } @ARGV); $ts = qx/date --iso-8601=seconds/; chomp $ts; exec "script ~/works/ssh-log/ssh-${ts}-${args}.log /usr/bin/ssh @ARGV"' $@
    tmux set-window-option window-status-current-format "#[fg=colour255,bg=#cc4400,bold] #I: #([[ '#W' != 'zsh' && '#W' != 'reattach-to-user-namespace' ]] && echo #W || ([ #{pane_current_path} = $HOME ] && echo 'HOME' || basename #{pane_current_path} )) "
    tmux set automatic-rename on
}

# function ssh() {
#   /usr/bin/env perl -e <<'EOF' $@
# use v5.12;
# use warnings;

# use utf8;
# use open IO => qw/:encoding(UTF-8) :std/;

# my $args = join '_', (grep { $_ !~ /^\-/ } @ARGV);

# my $timestamp = qx/date --iso-8601=seconds/;
# chomp $timestamp;

# exec "script ~/works/ssh-log/ssh-${timestamp}-${args}.log /usr/bin/ssh @ARGV"
# EOF
# }



## copy stdin to clipboard
# which xsel    >/dev/null 2>&1 && alias -g clip='xsel --input --clipboard' # Mac
# which pbcopy  >/dev/null 2>&1 && alias -g clip='pbcopy'                   # Linux
# which putclip >/dev/null 2>&1 && alias -g clip='putclip'                  # Cygwin
which xsel    >/dev/null 2>&1 && alias -g clip='tee >(xsel --input --clipboard)' # Mac
which pbcopy  >/dev/null 2>&1 && alias -g clip='tee >(pbcopy)'                   # Linux
which putclip >/dev/null 2>&1 && alias -g clip='tee >(putclip)'                  # Cygwin


## sts
alias stsext='eval `stsenv`'

## eks with sts
docker-eks () {
  local AWS_PRODUCT
  : ${AWS_PRODUCT:=$1}
  if [ -z "$AWS_PRODUCT" ]; then
    echo 'No AWS account specified. Please set to AWS_PRODUCT or pass as an argument'
    return 1
  fi

  export AWS_PRODUCT
  docker run -e AWS_PRODUCT -v ~/.dotfiles:/root/.dotfiles -v ~/.zshrc.zwc:/root/.zshrc.zwc --rm -it eks-work
  # export AWS_DEFAULT_REGION
  # docker run -e AWS_PRODUCT -e AWS_DEFAULT_REGION --rm -it eks-work
}

# gslookup
alias gslookup='/usr/bin/ssh op3 gslookup 2> /dev/null'

# cd repo
function repo() {
  REPO_ROOT=$(ls -d ${HOME}/works/*/repo)

  dir=$( (builtin cd $REPO_ROOT; find . -mindepth 2 -maxdepth 2 | peco) )
  [[ -z "$dir" ]] && return

  echo "${REPO_ROOT}/${dir}"
  cd "${REPO_ROOT}/${dir}"
}

# iab (グローバルエイリアス展開)
typeset -A abbreviations
abbreviations=(
  "Im"    "| more"
  "Ia"    "| awk"
  "Ig"    "| grep"
  "Ieg"   "| egrep"
  "Iag"   "| agrep"
  "Igr"   "| groff -s -p -t -e -Tlatin1 -mandoc"
  "Ip"    "| $PAGER"
  "Ih"    "| head"
  "Ik"    "| keep"
  "It"    "| tail"
  "Il"    "| less"
  "Is"    "| sort"
  "Iv"    "| ${VISUAL:-${EDITOR}}"
  "Iw"    "| wc"
  "Ix"    "| xargs"
  "NL"    ">/dev/null 2>&1 &"
)

magic-abbrev-expand() {
    local MATCH
    LBUFFER=${LBUFFER%%(#m)[-_a-zA-Z0-9]#}
    LBUFFER+=${abbreviations[$MATCH]:-$MATCH}
    zle self-insert
}

no-magic-abbrev-expand() {
  LBUFFER+=' '
}

zle -N magic-abbrev-expand
zle -N no-magic-abbrev-expand
bindkey " " magic-abbrev-expand
bindkey "^x " no-magic-abbrev-expand

alias pr='gh pr create -fw'
export LYNX_CFG=~/.lynx
#export EDITOR='emacsclient -t'
export CVSEDITOR="${EDITOR}"
export SVN_EDITOR="${EDITOR}"
export GIT_EDITOR="${EDITOR}"

# less command
#export VISUAL='emacsclient -t'
export LESS='-N -M -R'

export FZF_DEFAULT_OPTS="--cycle --no-mouse --reverse --prompt='QUERY> ' --color=16"

export LC_TIME='C'

export AWS_DEFAULT_REGION=ap-northeast-1
export KUBECTL_EXTERNAL_DIFF='colordiff -u'
# WSL 上のみ実行
if [[ `uname -a` =~ "Linux.*microsoft" ]]; then
  if [ "$INSIDE_EMACS" ]; then
    TERM=eterm-color
  fi

  umask 022
  export DISPLAY=localhost:0.0

  (
    command_path="/mnt/c/Program Files/VcXsrv/vcxsrv.exe"
    command_name=$(basename "$command_path")

    if ! tasklist.exe 2> /dev/null | fgrep -q "$command_name"; then
      # "$command_path" :0 -multiwindow -xkbmodel jp106 -xkblayout jp -clipboard -noprimary -wgl > /dev/null 2>&1 & # for jp-keyboard
  	  "$command_path" :0 -multiwindow -clipboard -noprimary -wgl > /dev/null 2>&1 & # for us-keyboard
    fi
  )
  alias emacs="NO_AT_BRIDGE=1 LIBGL_ALWAYS_INDIRECT=1 emacs"

  # 必要であれば、以下をアンコメント
  # keychain -q ~/.ssh/id_rsa
  # source ~/.keychain/$HOSTNAME-sh
fi

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


    function peco-cdr {
        local dir=$(cdr -l | peco | perl -pe 's/^\d+\s+//')
        if [ -n "$dir" ]; then
            BUFFER="cd ${dir}"
            zle accept-line
        fi
        zle clear-screen
    }
    zle -N peco-cdr
    bindkey '^v' peco-cdr
fi
autoload -Uz add-zsh-hook

function rename_tmux_window() {
    if [ $(echo $TERM | grep 'screen') ]; then
        tmux rename-window $(pwd)
    fi
}

# add-zsh-hook precmd rename_tmux_window
# peco の存在チェック
# if [ ! ${+commands[peco]} ]; then
#     return
# fi



# peco-history
function peco-select-history()
{
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi

    BUFFER=$(\history -n 1 | \
                 eval $tac | \
                 peco --query "$LBUFFER" | \
                 perl -pe 's/\\n/\n/g')
    CURSOR="$#BUFFER"
    # zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history



# peco snippet
function peco-snippets()
{
    local snippets="$HOME/.dotfiles/zsh/snippets.txt"

    if [ ! -e "$snippets" ]; then
        echo "$snippets is not found." >&2
        return 1
    fi

    local line="$(grep -v -e "^\s*#" -e "^\s*$" "$snippets"  | peco --query "$LBUFFER")"
    if [ -z "$line" ]; then
        return 1
    fi

    local snippet="$(echo "$line" | sed "s/^\[[^]]*\] *//g")"
    if [ -z "$snippet" ]; then
        return 1
    fi

    BUFFER=$snippet
    zle clear-screen
}
zle -N peco-snippets
bindkey '^x^x' peco-snippets



# peco cheatsheet
function peco-sni-cs()
{
    local cspath="$HOME/works/cheatsheet/.snip-peco-cheatsheet"

    if [ ! -e "$cspath" ]; then
        echo "$cspath is not found." >&2
        return 1
    fi

    local line="$(grep -v "^#" $cspath | peco --query "$LBUFFER")"
    if [ -z "$line" ]; then
        return 1
    fi

    local snippet="$(echo "$line" | sed "s/^\[[^]]*\] *//g")"
    if [ -z "$snippet" ]; then
        return 1
    fi

    BUFFER=$snippet
    zle clear-screen
}

zle -N peco-sni-cs
bindkey '^xc' peco-sni-cs



# peco-process-kill
function peco-pkill()
{
    for pid in `ps u | peco | awk '{ print $2 }'`
    do
        kill $pid
        echo "killed ${pid}"
    done
}
alias pk="peco-pkill"


# peco-process-kill-all
function peco-pkill-all()
{
    for pid in `ps aux | peco | awk '{ print $2 }'`
    do
        kill $pid
        echo "killed ${pid}"
    done
}
alias pka="peco-pkill-all"


# peco-process-kill-all
function peco-pkill-all-force()
{
    for pid in `ps aux | peco | awk '{ print $2 }'`
    do
        sudo kill -9 $pid
        echo "killed ${pid}"
    done
}
alias pka9="peco-pkill-all-force"



# peco-get-fullpath
function peco-get-fullpath()
{
    local fullpath
    if [ ! -z "$1" ]; then
        if [ -f $1 ]; then
            fullpath=`pwd`/$1
        else
            fullpath=$(find `pwd`/$1 -maxdepth 1 -mindepth 1 | peco --query "$LBUFFER")
        fi
    else
        fullpath=$(find `pwd` -maxdepth 1 -mindepth 1 | peco --query "$LBUFFER")
    fi
    echo "${fullpath}" | pbcopy
    echo ${fullpath}
}
alias fullpath="peco-get-fullpath"



# peco-cd
function peco-cd()
{
    while true
    do
        local selected_dir=$(ls -al | grep / | awk '{print $9}' | peco 2> /dev/null)

        if [ "$selected_dir" = "./" ]; then
            BUFFER=""
            break;
        fi

        if [ -n "$selected_dir" ]; then
            BUFFER="cd ${selected_dir}"
            zle accept-line
            cd "$selected_dir"
        else
            break;
        fi
    done
    zle clear-screen
}
zle -N peco-cd
bindkey '^x^f' peco-cd



# peco-nmcli-wifi-connect
function peco-wlcon()
{
    local ssid=$(nmcli dev wifi list | tail -n +2 | peco --query "$*" | awk '{print $1}')
    print -z "nmcli dev wifi connect \"${ssid}\" password "
}
alias wlcon="peco-wlcon"



function peco-pcd()
{
    local path=$(cat -)

    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
        cd "$selected_dir"
    else
        break;
    fi
    zle clear-screen
}
zle -N peco-pcd
#bindkey '' pcd


function rmpeco()
{
    rm $(ls --almost-all | peco)
}


function rmpeco-rf()
{
    rm -rf $(ls --almost-all | peco)
}


function peco-ssh () {
  #   local selected_host=$(awk '
  # tolower($1)=="host" {
  #   for (i=2; i<=NF; i++) {
  #     if ($i !~ "[*?]") {
  #       print $i
  #     }
  #   }
  # }
  # ' ~/.ssh/config | sort | peco --query "$LBUFFER")
  #   if [ -n "$selected_host" ]; then
  #       BUFFER="ssh ${selected_host}"
  #       zle accept-line
  #   fi
  #   zle clear-screen

  local selected_host=$(perl ~/bin/peco-ssh.pl)
  if [ -n "$selected_host" ]; then
    BUFFER="ssh ${selected_host}"
    CURSOR=$#BUFFER
    # zle accept-line
  fi
  # zle clear-screen
}
zle -N peco-ssh
bindkey '^\' peco-ssh


function peco-kubectx () {
    kubectx $(kubectx | peco)
}
zle -N peco-kubectx
bindkey '^x^k' peco-kubectx


function sp()
{
    ssh $(grep -E '^Host' $HOME/.ssh/config | \
              perl -ne 'm/Host\s+.*?(\S+)(\s+(\S+))?/;
                    printf "[ %-15s ] $1\n", $3;' | \
                        grep -vE 'bitbucket|gitlab|lab-router' | \
                        peco                                   | \
                        sed -e 's/^\[.*\]\s*//g')
}


function peco-nmcli()
{
    nmcli $(nmcli 2>&1 | sed -e '/Usage/,/OBJECT/d' | perl -pe 's/[\[\]]//g' | peco | awk '{print $1}')
}
zle -N peco-nmcli
bindkey '^x^r' peco-nmcli


function peco-file() {
    ls -l --almost-all --si --time-style=long-iso $1 \
        | grep -P -v 'total [^ ]*' \
        | peco \
        | perl -alE 'say $F[7]'
}



# peco todo
function peco-open-todo()
{
    local snippets="$HOME/.dotfiles/zsh/note-files.txt"

    if [ ! -e "$snippets" ]; then
        echo "$snippets is not found." >&2
        return 1
    fi

    local line="$(grep -v "^#" "$snippets" | peco --query "$LBUFFER")"
    if [ -z "$line" ]; then
        return 1
    fi

    local snippet="$(echo "$line" | sed "s/^\[[^]]*\] *//g")"
    if [ -z "$snippet" ]; then
        return 1
    fi

    BUFFER=$snippet
    zle clear-screen
}

zle -N peco-open-todo
bindkey '^xt' peco-open-todo



# peco make
function peco-make()
{
    local recipe=$(ggrep -P '^\S+:' Makefile | sed 's/:.*$//g' | peco)
    if [ -n "$recipe" ]; then
        BUFFER="make ${recipe}"
        zle accept-line
    fi
    zle clear-screen
}

zle -N peco-make
bindkey '^[m' peco-make

## git status
function git-status()
{
    # if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
        echo git status -sb
        git status -sb
        echo '\n'
    # fi
    zle reset-prompt
}
zle -N git-status
bindkey "^gs" git-status


## git diff
function peco-git-diff()
{
    local O_PWD=$(pwd)
    local GIT_ROOT=$(perl -e "print '$O_PWD' . '/..' x $(get-git-dir-depth)")

    cd $GIT_ROOT 2> /dev/null

    if [ $(git status --porcelain | wc -l) -eq 0 ]; then
        echo $(git status | perl -pe 's/On branch (.*)/[branch: $1] /')
        return
    fi

    local SELECTED_FILE_TO_DIFF="$(git status --porcelain | \
                                  grep '^ *M' | \
                                  peco --query "$LBUFFER" | \
                                  awk -F ' ' '{print $NF}')"
    if [ -n "$SELECTED_FILE_TO_DIFF" ]; then
        git diff $(echo "$SELECTED_FILE_TO_DIFF" | tr '\n' ' ')
    else
        echo 'Not found the file.'
    fi

    cd $O_PWD > /dev/null
    zle reset-prompt
}
zle -N peco-git-diff
bindkey "^gd" peco-git-diff


## git add
function peco-git-add()
{
    local SELECTED_FILE_TO_ADD="$(git status --short | \
                                  peco --query "$LBUFFER" | \
                                  awk -F ' ' '{print $NF}')"
    if [ -n "$SELECTED_FILE_TO_ADD" ]; then
      BUFFER="git add $(echo "$SELECTED_FILE_TO_ADD" | tr '\n' ' ')"
      CURSOR=$#BUFFER
    fi
    zle accept-line
    zle reset-prompt
}
zle -N peco-git-add
bindkey "^ga" peco-git-add


## git checkout
function peco-git-checkout()
{
    git checkout $(git branch -a | peco | sed -e 's/^..//g' -e '/->/d' | awk '!a[$0]++')
    zle reset-prompt
}
zle -N peco-git-checkout
bindkey "^go" peco-git-checkout


## git graph
function __git-graph()
{
    git log --graph --all --pretty=format:'%C(green)%cd%C(reset) %C(red)%h%C(reset) %C(yellow bold)%d%C(reset) %C(bold)%s%C(reset) %C(blue bold)<%an>%C(reset)' --abbrev-commit --date=format:'%Y-%m-%d %H:%M'
    zle reset-prompt
}
zle -N __git-graph
bindkey "^gg" __git-graph


## git graph rich
function __git-graph-rich()
{
    git log --graph --all --pretty=format:'%C(red reverse)%d%Creset%C(white reverse) %h% Creset %C(green reverse) %an %Creset %C(cyan bold)%ad (%ar)%Creset%n%C(white bold)%w(80)%s%Creset%n%n%w(80,2,2)%b' --abbrev-commit --date=format:'%Y-%m-%d %H:%M:%S' --name-status
    zle reset-prompt
}
zle -N __git-graph-rich
bindkey "^g^g" __git-graph-rich


## git commit -v
function __git-commit()
{
    # git commit -v
    # zle reset-prompt
    BUFFER="git commit -m ''"
    CURSOR=15

}
zle -N __git-commit
bindkey "^gc" __git-commit


## git commit -v
function cd-git-root()
{
    if [[ $(get-git-dir-depth) != '0' ]]; then
        cd $(get-git-root-dir)
    fi
    zle reset-prompt
}
zle -N cd-git-root
bindkey "^gr" cd-git-root


function get-git-root-dir()
{
    if [[ $(get-git-dir-depth) != '0' ]]; then
        local REL_PATH_FROM_GIT_ROOT=$(get-path-from-git-root | perl -pe 's!/$!!')
        pwd | perl -pe "s!${REL_PATH_FROM_GIT_ROOT}/?\$!!"
    fi
}


function get-git-dir-depth
{
    local depth=$(get-path-from-git-root | head -n 1 | perl -ne 'print s!/!!g')
    if [[ $depth == '' ]];then
        echo '0'
    else
        echo $depth
    fi
}
## Start tmux automatically on ssh shell
# https://gist.github.com/ABCanG/11bfcff22a0633600aefbb01550b8e38

#if [[ -n "${REMOTEHOST}${SSH_CONNECTION}" && -z "$TMUX" && -z "$STY" ]] && type tmux >/dev/null 2>&1; then
if [[ -z "$TMUX" && -z "$STY" ]] && type tmux >/dev/null 2>&1; then
    function confirm {
        MSG=$1
        while :
        do
            echo -n "${MSG} [Y/n]: "
            read ans
            case $ans in
                "" | "y" | "Y" | "yes" | "Yes" | "YES" ) return 0 ;;
                *                                      ) return 1 ;;
            esac
        done
    }
    option=""
    if [ ${+commands[tmux]} -gt 0 ] && tmux has-session && tmux list-sessions; then
        option="attach"
    fi
    [ ${+commands[tmux]} -gt 0 ] && tmux $option && confirm "exit?" && exit
fi
function pcolor()
{
    for ((f = 0; f < 255; f++)); do
        printf "\e[38;5;%dm %3d*■\e[m" $f $f
        if [[ $f%8 -eq 7 ]] then
            printf "\n"
        fi
        done
    echo
}

function battery-pc()
{
	local percentage=$(cat /sys/class/power_supply/BAT1/uevent | grep CAPACITY= | cut -d = -f2)
	echo "Battery : $percentage%"
}

function cc5()
{
    perl -E "print ($*)"
}


function mdisp()
{
    selected=$(
		/bin/cat <<EOF |
[ built-in | HDMI ] xrandr --output eDP-1 --auto --output DP-1 --auto --right-of eDP-1
[ HDMI | built-in ] xrandr --output DP-1 --auto --output eDP-1 --auto --right-of DP-1
[    same (HDMI)  ] xrandr --output DP-1 --auto --same-as eDP-1
[     HDMI off    ] xrandr --output DP-1 --off
[ built-in | VGA  ] xrandr --output eDP-1 --auto --output DP-2 --auto --right-of eDP-1
[  VGA | built-in ] xrandr --output DP-2 --auto --output eDP-1 --auto --right-of DP-2
[    same  (VGA)  ] xrandr --output DP-2 --auto --same-as eDP-1
[     VGA  off    ] xrandr --output DP-2 --off
[  VGA  FULL-HD   ] xrandr --addmode DP-2 1920x1080
[  HDMI FULL-HD   ] xrandr --addmode DP-1 1920x1080
EOF
		peco )

	BUFFER="$(echo "$selected" | sed "s/^\[[^]]*\] *//g")"

    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N mdisp
bindkey '^x^m' mdisp


function set-brightness-usage()
{
	echo "usage:" >&2
	echo "   set-brightness <value>" >&2
	echo "   <value> is an integer between 20 and 100." >&2
	return
}

function set-brightness()
{
	prefix="/sys/class/backlight/intel_backlight"

	if [ ! -e ${prefix}/max_brightness ]; then
		echo 'This script does not work. $prefix is wrong.'
		return
	fi

	## check argument
	if [ -z "${@}" ]; then
		set-brightness-usage
		return
	fi

	## Parse the first argument. (Non-numeric : zero)
	value=$(echo ${1:?} | awk '{print $1*1}')
	if [ ${value} -gt 100 -o ${value} -lt 20 ]; then
		set-brightness-usage
		return
	fi

	MAX_VALUE=$(cat ${prefix}/max_brightness)
	value=$(echo "${MAX_VALUE} * ${value} / 100" | bc)

	echo ${value} | sudo tee ${prefix}/brightness >/dev/null
}



function mount-usb-exfat()
{
    mount -t "exfat" -o "uhelper=udisks2,nodev,nosuid,uid=1000,gid=1000,iocharset=utf8,namecase=0,errors=remount-ro,umask=0077" "/dev/sdb1" "/mnt/usb"
}

function mount-usb-fat32()
{
    mount -t "fat32" -o "uhelper=udisks2,nodev,nosuid,uid=1000,gid=1000,iocharset=utf8,namecase=0,errors=remount-ro,umask=0077" "/dev/sdb1" "/mnt/usb"
}

function mount-usb-ntfs()
{
    mount -t "ntfs" -o "uhelper=udisks2,nodev,nosuid,uid=1000,gid=1000,iocharset=utf8,namecase=0,errors=remount-ro,umask=0077" "/dev/sdb1" "/mnt/usb"
}

function win10()
{
    remmina &
    sudo kvm -hda ~/kvm/win10_x64.qcow2 -boot c -m 2048 -vnc :0 -monitor stdio -usbdevice tablet
}

function tree()
{
    pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'
}

function dict()
{
    hw -A 1 -w --color --no-line-number $1 ~/dicts/gene-utf8.txt | head | sed -e 's/^.*://g'
}

function lock()
{
    dm-tool loack
}
alias gslookup='/usr/bin/ssh op gslookup 2> /dev/null'

# teleport ssh
function tssh() {
    # /usr/bin/ssh -J teleport.security.gree-dev.net:3023 -l yuki-osako $(tsh ls | perl -F'\s' -alnE '/^\w/ and say $F[0]' | peco)

    perl ~/tmp/tssh
}


export TELEPORT_AUTH=gree-sso
export TELEPORT_LOGIN=yuki-osako
export TELEPORT_PROXY=teleport.security.gree-dev.net:3080
## period
function show-time()
{
    echo ""
    LC_TIME=c date --iso-8601=minutes | sed -e 's/T/ /g' -e 's/^(.*)$/($1)/'
}
PERIOD=30
add-zsh-hook periodic show-time


function auto-sts() {
    if [[ -z "$AWS_PRODUCT" ]]; then
         unset AWS_SECURITY_TOKEN
    else
      if [[ -z "$STS_EXPIRATION_UNIXTIME" ]]; then
          echo "\ngetting sts token...\n"
          export _STS_CURRENT_AWS_PRODUCT=$AWS_PRODUCT
          eval `stsenv`
      elif [[ "$_STS_CURRENT_AWS_PRODUCT" != "$AWS_PRODUCT" ]]; then
          echo "\nupdating sts token for account switching...\n"
          export _STS_CURRENT_AWS_PRODUCT=$AWS_PRODUCT
          eval `stsenv`
      elif [[ "$STS_EXPIRATION_UNIXTIME" -lt `date +%s` ]]; then
          echo "\nupdating sts token...\n"
          # export _STS_CURRENT_AWS_PRODUCT=$AWS_PRODUCT
          eval `stsenv`
      fi
    fi
}


function _precmd() {
    auto-sts
    update-prompt
}
add-zsh-hook precmd _precmd



#compdef _eksctl eksctl


function _eksctl {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "create:Create resource(s)"
      "get:Get resource(s)"
      "update:Update resource(s)"
      "upgrade:Upgrade resource(s)"
      "delete:Delete resource(s)"
      "set:Set values"
      "unset:Unset values"
      "scale:Scale resources(s)"
      "drain:Drain resource(s)"
      "utils:Various utils"
      "completion:Generates shell completion scripts"
      "version:Output the version of eksctl"
      "help:Help about any command"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  create)
    _eksctl_create
    ;;
  get)
    _eksctl_get
    ;;
  update)
    _eksctl_update
    ;;
  upgrade)
    _eksctl_upgrade
    ;;
  delete)
    _eksctl_delete
    ;;
  set)
    _eksctl_set
    ;;
  unset)
    _eksctl_unset
    ;;
  scale)
    _eksctl_scale
    ;;
  drain)
    _eksctl_drain
    ;;
  utils)
    _eksctl_utils
    ;;
  completion)
    _eksctl_completion
    ;;
  version)
    _eksctl_version
    ;;
  help)
    _eksctl_help
    ;;
  esac
}


function _eksctl_create {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "cluster:Create a cluster"
      "nodegroup:Create a nodegroup"
      "iamserviceaccount:Create an iamserviceaccount - AWS IAM role bound to a Kubernetes service account"
      "iamidentitymapping:Create an IAM identity mapping"
      "fargateprofile:Create a Fargate profile"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  cluster)
    _eksctl_create_cluster
    ;;
  nodegroup)
    _eksctl_create_nodegroup
    ;;
  iamserviceaccount)
    _eksctl_create_iamserviceaccount
    ;;
  iamidentitymapping)
    _eksctl_create_iamidentitymapping
    ;;
  fargateprofile)
    _eksctl_create_fargateprofile
    ;;
  esac
}

function _eksctl_create_cluster {
  _arguments \
    '--alb-ingress-access[enable full access for alb-ingress-controller]' \
    '--appmesh-access[enable full access to AppMesh]' \
    '--asg-access[enable IAM policy for cluster-autoscaler]' \
    '--authenticator-role-arn[AWS IAM role to assume for authenticator]:' \
    '--auto-kubeconfig[save kubeconfig file by cluster name, e.g. "/Users/yuki.osako/.kube/eksctl/clusters/extravagant-badger-1581992561"]' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--external-dns-access[enable IAM policy for external-dns]' \
    '--fargate[Create a Fargate profile scheduling pods in the default and kube-system namespaces onto Fargate]' \
    '--full-ecr-access[enable full access to ECR]' \
    '--install-vpc-controllers[Install VPC controller that'\''s required for Windows workloads]' \
    '--kubeconfig[path to write kubeconfig (incompatible with --auto-kubeconfig)]:' \
    '--managed[Create EKS-managed nodegroup]' \
    '--max-pods-per-node[maximum number of pods per node (set automatically if unspecified)]:' \
    '(-n --name)'{-n,--name}'[EKS cluster name (generated if unspecified, e.g. "extravagant-badger-1581992561")]:' \
    '--node-ami[Advanced use cases only. If '\''static'\'' is supplied (default) then eksctl will use static AMIs; if '\''auto'\'' is supplied then eksctl will automatically set the AMI based on version/region/instance type; if any other value is supplied it will override the AMI to use for the nodes. Use with extreme care.]:' \
    '--node-ami-family[Advanced use cases only. If '\''AmazonLinux2'\'' is supplied (default), then eksctl will use the official AWS EKS AMIs (Amazon Linux 2); if '\''Ubuntu1804'\'' is supplied, then eksctl will use the official Canonical EKS AMIs (Ubuntu 18.04).]:' \
    '--node-labels[Extra labels to add when registering the nodes in the nodegroup, e.g. "partition=backend,nodeclass=hugememory"]:' \
    '(-P --node-private-networking)'{-P,--node-private-networking}'[whether to make nodegroup networking private]' \
    '*--node-security-groups[Attach additional security groups to nodes, so that it can be used to allow extra ingress/egress access from/to pods]:' \
    '(-t --node-type)'{-t,--node-type}'[node instance type]:' \
    '--node-volume-size[node volume size in GB]:' \
    '--node-volume-type[node volume type (valid options: gp2, io1, sc1, st1)]:' \
    '*--node-zones[(inherited from the cluster if unspecified)]:' \
    '--nodegroup-name[name of the nodegroup (generated if unspecified, e.g. "ng-d724d7c5")]:' \
    '(-N --nodes)'{-N,--nodes}'[total number of nodes (for a static ASG)]:' \
    '(-M --nodes-max)'{-M,--nodes-max}'[maximum nodes in ASG]:' \
    '(-m --nodes-min)'{-m,--nodes-min}'[minimum nodes in ASG]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--set-kubeconfig-context[if true then current-context will be set in kubeconfig; if a context is already set then it will be overwritten]' \
    '--ssh-access[control SSH access for nodes. Uses ~/.ssh/id_rsa.pub as default key path if enabled]' \
    '--ssh-public-key[SSH public key to use for nodes (import from local path, or use existing EC2 key pair)]:' \
    '--tags[A list of KV pairs used to tag the AWS resources (e.g. "Owner=John Doe,Team=Some Team")]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--version[Kubernetes version (valid options: 1.12, 1.13, 1.14)]:' \
    '--vpc-cidr[global CIDR to use for VPC]:' \
    '--vpc-from-kops-cluster[re-use VPC from a given kops cluster]:' \
    '--vpc-nat-mode[VPC NAT mode, valid options: HighlyAvailable, Single, Disable]:' \
    '*--vpc-private-subnets[re-use private subnets of an existing VPC]:' \
    '*--vpc-public-subnets[re-use public subnets of an existing VPC]:' \
    '--without-nodegroup[if set, initial nodegroup will not be created]' \
    '--write-kubeconfig[toggle writing of kubeconfig]' \
    '*--zones[(auto-select if unspecified)]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_create_nodegroup {
  _arguments \
    '--alb-ingress-access[enable full access for alb-ingress-controller]' \
    '--appmesh-access[enable full access to AppMesh]' \
    '--asg-access[enable IAM policy for cluster-autoscaler]' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[name of the EKS cluster to add the nodegroup to]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--exclude[nodegroups to exclude (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '--external-dns-access[enable IAM policy for external-dns]' \
    '--full-ecr-access[enable full access to ECR]' \
    '*--include[nodegroups to include (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '--managed[Create EKS-managed nodegroup]' \
    '--max-pods-per-node[maximum number of pods per node (set automatically if unspecified)]:' \
    '(-n --name)'{-n,--name}'[name of the new nodegroup (generated if unspecified, e.g. "ng-55858656")]:' \
    '--node-ami[Advanced use cases only. If '\''static'\'' is supplied (default) then eksctl will use static AMIs; if '\''auto'\'' is supplied then eksctl will automatically set the AMI based on version/region/instance type; if any other value is supplied it will override the AMI to use for the nodes. Use with extreme care.]:' \
    '--node-ami-family[Advanced use cases only. If '\''AmazonLinux2'\'' is supplied (default), then eksctl will use the official AWS EKS AMIs (Amazon Linux 2); if '\''Ubuntu1804'\'' is supplied, then eksctl will use the official Canonical EKS AMIs (Ubuntu 18.04).]:' \
    '--node-labels[Extra labels to add when registering the nodes in the nodegroup, e.g. "partition=backend,nodeclass=hugememory"]:' \
    '(-P --node-private-networking)'{-P,--node-private-networking}'[whether to make nodegroup networking private]' \
    '*--node-security-groups[Attach additional security groups to nodes, so that it can be used to allow extra ingress/egress access from/to pods]:' \
    '(-t --node-type)'{-t,--node-type}'[node instance type]:' \
    '--node-volume-size[node volume size in GB]:' \
    '--node-volume-type[node volume type (valid options: gp2, io1, sc1, st1)]:' \
    '*--node-zones[(inherited from the cluster if unspecified)]:' \
    '(-N --nodes)'{-N,--nodes}'[total number of nodes (for a static ASG)]:' \
    '(-M --nodes-max)'{-M,--nodes-max}'[maximum nodes in ASG]:' \
    '(-m --nodes-min)'{-m,--nodes-min}'[minimum nodes in ASG]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--ssh-access[control SSH access for nodes. Uses ~/.ssh/id_rsa.pub as default key path if enabled]' \
    '--ssh-public-key[SSH public key to use for nodes (import from local path, or use existing EC2 key pair)]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--update-auth-configmap[Remove nodegroup IAM role from aws-auth configmap]' \
    '--version[Kubernetes version (valid options: 1.12, 1.13, 1.14) [for nodegroups "auto" and "latest" can be used to automatically inherit version from the control plane or force latest]]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_create_iamserviceaccount {
  _arguments \
    '--approve[Apply the changes]' \
    '*--attach-policy-arn[ARN of the policy where to create the iamserviceaccount]:' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[name of the EKS cluster to add the iamserviceaccount to]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--exclude[iamserviceaccounts to exclude (list of globs), e.g.: '\''default/s3-reader,*/dynamo-*'\'']:' \
    '*--include[iamserviceaccounts to include (list of globs), e.g.: '\''default/s3-reader,*/dynamo-*'\'']:' \
    '--name[name of the iamserviceaccount to create]:' \
    '--namespace[namespace where to create the iamserviceaccount]:' \
    '--override-existing-serviceaccounts[create IAM roles for existing serviceaccounts and update the serviceaccount]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_create_iamidentitymapping {
  _arguments \
    '--arn[ARN of the IAM role or user to create]:' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--group[Group within Kubernetes to which IAM role is mapped]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--username[User name within Kubernetes to map to IAM role]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_create_fargateprofile {
  _arguments \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-l --labels)'{-l,--labels}'[Kubernetes selector labels of the workloads to schedule on Fargate, e.g. k1=v1,k2=v2]:' \
    '--name[Fargate profile'\''s name]:' \
    '--namespace[Kubernetes namespace of the workloads to schedule on Fargate]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_get {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "cluster:Get cluster(s)"
      "nodegroup:Get nodegroup(s)"
      "iamserviceaccount:Get iamserviceaccount(s)"
      "iamidentitymapping:Get IAM identity mapping(s)"
      "labels:Get nodegroup labels"
      "fargateprofile:Get Fargate profile(s)"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  cluster)
    _eksctl_get_cluster
    ;;
  nodegroup)
    _eksctl_get_nodegroup
    ;;
  iamserviceaccount)
    _eksctl_get_iamserviceaccount
    ;;
  iamidentitymapping)
    _eksctl_get_iamidentitymapping
    ;;
  labels)
    _eksctl_get_labels
    ;;
  fargateprofile)
    _eksctl_get_fargateprofile
    ;;
  esac
}

function _eksctl_get_cluster {
  _arguments \
    '(-A --all-regions)'{-A,--all-regions}'[List clusters across all supported regions]' \
    '--chunk-size[return large lists in chunks rather than all at once, pass 0 to disable]:' \
    '(-n --name)'{-n,--name}'[EKS cluster name]:' \
    '(-o --output)'{-o,--output}'[specifies the output format (valid option: table, json, yaml)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_get_nodegroup {
  _arguments \
    '--chunk-size[return large lists in chunks rather than all at once, pass 0 to disable]:' \
    '--cluster[EKS cluster name]:' \
    '(-n --name)'{-n,--name}'[Name of the nodegroup]:' \
    '(-o --output)'{-o,--output}'[specifies the output format (valid option: table, json, yaml)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_get_iamserviceaccount {
  _arguments \
    '--chunk-size[return large lists in chunks rather than all at once, pass 0 to disable]:' \
    '--cluster[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--name[name of the iamserviceaccount to delete]:' \
    '--namespace[namespace where to delete the iamserviceaccount]:' \
    '(-o --output)'{-o,--output}'[specifies the output format (valid option: table, json, yaml)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_get_iamidentitymapping {
  _arguments \
    '--arn[ARN of the IAM role or user to create]:' \
    '--chunk-size[return large lists in chunks rather than all at once, pass 0 to disable]:' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-o --output)'{-o,--output}'[specifies the output format (valid option: table, json, yaml)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_get_labels {
  _arguments \
    '--cluster[EKS cluster name]:' \
    '(-n --nodegroup)'{-n,--nodegroup}'[Nodegroup name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_get_fargateprofile {
  _arguments \
    '--chunk-size[return large lists in chunks rather than all at once, pass 0 to disable]:' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--name[Fargate profile'\''s name]:' \
    '(-o --output)'{-o,--output}'[specifies the output format (valid option: table, json, yaml)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_update {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "cluster:Update cluster"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  cluster)
    _eksctl_update_cluster
    ;;
  esac
}

function _eksctl_update_cluster {
  _arguments \
    '--approve[Apply the changes]' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-n --name)'{-n,--name}'[EKS cluster name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_upgrade {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "nodegroup:Upgrade nodegroup"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  nodegroup)
    _eksctl_upgrade_nodegroup
    ;;
  esac
}

function _eksctl_upgrade_nodegroup {
  _arguments \
    '--cluster[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--kubernetes-version[Kubernetes version]:' \
    '--name[Nodegroup name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_delete {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "cluster:Delete a cluster"
      "nodegroup:Delete a nodegroup"
      "iamserviceaccount:Delete an IAM service account"
      "iamidentitymapping:Delete a IAM identity mapping"
      "fargateprofile:Delete Fargate profile"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  cluster)
    _eksctl_delete_cluster
    ;;
  nodegroup)
    _eksctl_delete_nodegroup
    ;;
  iamserviceaccount)
    _eksctl_delete_iamserviceaccount
    ;;
  iamidentitymapping)
    _eksctl_delete_iamidentitymapping
    ;;
  fargateprofile)
    _eksctl_delete_fargateprofile
    ;;
  esac
}

function _eksctl_delete_cluster {
  _arguments \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-n --name)'{-n,--name}'[EKS cluster name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-w --wait)'{-w,--wait}'[wait for deletion of all resources before exiting]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_delete_nodegroup {
  _arguments \
    '--approve[Apply the changes]' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--drain[Drain and cordon all nodes in the nodegroup before deletion]' \
    '*--exclude[nodegroups to exclude (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '*--include[nodegroups to include (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '(-n --name)'{-n,--name}'[Name of the nodegroup to delete]:' \
    '--only-missing[Only delete nodegroups that are not defined in the given config file]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--update-auth-configmap[Remove nodegroup IAM role from aws-auth configmap]' \
    '(-w --wait)'{-w,--wait}'[wait for deletion of all resources before exiting]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_delete_iamserviceaccount {
  _arguments \
    '--approve[Apply the changes]' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[name of the EKS cluster to delete the iamserviceaccount from]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--exclude[iamserviceaccounts to exclude (list of globs), e.g.: '\''default/s3-reader,*/dynamo-*'\'']:' \
    '*--include[iamserviceaccounts to include (list of globs), e.g.: '\''default/s3-reader,*/dynamo-*'\'']:' \
    '--name[name of the iamserviceaccount to delete]:' \
    '--namespace[namespace where to delete the iamserviceaccount]:' \
    '--only-missing[Only delete nodegroups that are not defined in the given config file]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-w --wait)'{-w,--wait}'[wait for deletion of all resources before exiting]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_delete_iamidentitymapping {
  _arguments \
    '--all[Delete all matching mappings instead of just one]' \
    '--arn[ARN of the IAM role or user to create]:' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_delete_fargateprofile {
  _arguments \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--name[Fargate profile'\''s name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-w --wait)'{-w,--wait}'[wait for wait for the deletion of the Fargate profile, which may take from a couple seconds to a couple minutes. before exiting]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_set {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "labels:Create or overwrite labels"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  labels)
    _eksctl_set_labels
    ;;
  esac
}

function _eksctl_set_labels {
  _arguments \
    '--cluster[EKS cluster name]:' \
    '(-l --labels)'{-l,--labels}'[Create Labels]:' \
    '(-n --nodegroup)'{-n,--nodegroup}'[Nodegroup name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_unset {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "labels:Create removeLabels"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  labels)
    _eksctl_unset_labels
    ;;
  esac
}

function _eksctl_unset_labels {
  _arguments \
    '--cluster[EKS cluster name]:' \
    '(*-l *--labels)'{\*-l,\*--labels}'[List of labels to remove]:' \
    '(-n --nodegroup)'{-n,--nodegroup}'[Nodegroup name]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_scale {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "nodegroup:Scale a nodegroup"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  nodegroup)
    _eksctl_scale_nodegroup
    ;;
  esac
}

function _eksctl_scale_nodegroup {
  _arguments \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[EKS cluster name]:' \
    '(-n --name)'{-n,--name}'[Name of the nodegroup to scale]:' \
    '(-N --nodes)'{-N,--nodes}'[total number of nodes (scale to this number)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_drain {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "nodegroup:Cordon and drain a nodegroup"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  nodegroup)
    _eksctl_drain_nodegroup
    ;;
  esac
}

function _eksctl_drain_nodegroup {
  _arguments \
    '--approve[Apply the changes]' \
    '--cfn-role-arn[IAM role used by CloudFormation to call AWS API on your behalf]:' \
    '--cluster[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--exclude[nodegroups to exclude (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '*--include[nodegroups to include (list of globs), e.g.: '\''ng-team-?,prod-*'\'']:' \
    '(-n --name)'{-n,--name}'[Name of the nodegroup to delete]:' \
    '--only-missing[Only drain nodegroups that are not defined in the given config file]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--undo[Uncordone the nodegroup]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_utils {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "wait-nodes:Wait for nodes"
      "write-kubeconfig:Write kubeconfig file for a given cluster"
      "describe-stacks:Describe CloudFormation stack for a given cluster"
      "update-cluster-stack:DEPRECATED: Use 'eksctl update cluster' instead"
      "update-kube-proxy:Update kube-proxy add-on to ensure image matches Kubernetes control plane version"
      "update-aws-node:Update aws-node add-on to latest released version"
      "update-coredns:Update coredns add-on to ensure image matches the standard Amazon EKS version"
      "update-cluster-logging:Update cluster logging configuration"
      "associate-iam-oidc-provider:Setup IAM OIDC provider for a cluster to enable IAM roles for pods"
      "install-vpc-controllers:Install Windows VPC controller to support running Windows workloads"
      "update-cluster-endpoints:Update Kubernetes API endpoint access configuration"
      "set-public-access-cidrs:Update public access CIDRs"
      "nodegroup-health:Get nodegroup health for a managed node"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  wait-nodes)
    _eksctl_utils_wait-nodes
    ;;
  write-kubeconfig)
    _eksctl_utils_write-kubeconfig
    ;;
  describe-stacks)
    _eksctl_utils_describe-stacks
    ;;
  update-cluster-stack)
    _eksctl_utils_update-cluster-stack
    ;;
  update-kube-proxy)
    _eksctl_utils_update-kube-proxy
    ;;
  update-aws-node)
    _eksctl_utils_update-aws-node
    ;;
  update-coredns)
    _eksctl_utils_update-coredns
    ;;
  update-cluster-logging)
    _eksctl_utils_update-cluster-logging
    ;;
  associate-iam-oidc-provider)
    _eksctl_utils_associate-iam-oidc-provider
    ;;
  install-vpc-controllers)
    _eksctl_utils_install-vpc-controllers
    ;;
  update-cluster-endpoints)
    _eksctl_utils_update-cluster-endpoints
    ;;
  set-public-access-cidrs)
    _eksctl_utils_set-public-access-cidrs
    ;;
  nodegroup-health)
    _eksctl_utils_nodegroup-health
    ;;
  esac
}

function _eksctl_utils_wait-nodes {
  _arguments \
    '--kubeconfig[path to read kubeconfig]:' \
    '(-m --nodes-min)'{-m,--nodes-min}'[minimum number of nodes to wait for]:' \
    '--timeout[how long to wait]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_write-kubeconfig {
  _arguments \
    '--authenticator-role-arn[AWS IAM role to assume for authenticator]:' \
    '--auto-kubeconfig[save kubeconfig file by cluster name, e.g. "/Users/yuki.osako/.kube/eksctl/clusters/<name>"]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '--kubeconfig[path to write kubeconfig (incompatible with --auto-kubeconfig)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--set-kubeconfig-context[if true then current-context will be set in kubeconfig; if a context is already set then it will be overwritten]' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_describe-stacks {
  _arguments \
    '--all[include deleted stacks]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '--events[include stack events]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '--trail[lookup CloudTrail events for the cluster]' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-cluster-stack {
  _arguments \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-kube-proxy {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-aws-node {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-coredns {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-cluster-logging {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '*--disable-types[Log types to be disabled, the rest will be disabled. Supported log types: (all, none, api, audit, authenticator, controllerManager, scheduler)]:' \
    '*--enable-types[Log types to be enabled. Supported log types: (all, none, api, audit, authenticator, controllerManager, scheduler)]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_associate-iam-oidc-provider {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_install-vpc-controllers {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_update-cluster-endpoints {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '--private-access[access for private (VPC) clients]' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '--public-access[access for public clients]' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_set-public-access-cidrs {
  _arguments \
    '--approve[Apply the changes]' \
    '(-c --cluster)'{-c,--cluster}'[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_utils_nodegroup-health {
  _arguments \
    '--cluster[EKS cluster name]:' \
    '(-f --config-file)'{-f,--config-file}'[load configuration from a file (or stdin if set to '\''-'\'')]:' \
    '(-n --name)'{-n,--name}'[Name of the nodegroup]:' \
    '(-p --profile)'{-p,--profile}'[AWS credentials profile to use (overrides the AWS_PROFILE environment variable)]:' \
    '(-r --region)'{-r,--region}'[AWS region]:' \
    '--timeout[maximum waiting time for any long-running operation]:' \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}


function _eksctl_completion {
  local -a commands

  _arguments -C \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:' \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "bash:Generates bash completion scripts"
      "zsh:Generates zsh completion scripts"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  bash)
    _eksctl_completion_bash
    ;;
  zsh)
    _eksctl_completion_zsh
    ;;
  esac
}

function _eksctl_completion_bash {
  _arguments \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_completion_zsh {
  _arguments \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_version {
  _arguments \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

function _eksctl_help {
  _arguments \
    '(-C --color)'{-C,--color}'[toggle colorized logs (valid options: true, false, fabulous)]:' \
    '(-h --help)'{-h,--help}'[help for this command]' \
    '(-v --verbose)'{-v,--verbose}'[set log level, use 0 to silence, 4 for debugging and 5 for debugging with AWS debug logging]:'
}

source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
#compdef helm

__helm_bash_source() {
	alias shopt=':'
	alias _expand=_bash_expand
	alias _complete=_bash_comp
	emulate -L sh
	setopt kshglob noshglob braceexpand
	source "$@"
}
__helm_type() {
	# -t is not supported by zsh
	if [ "$1" == "-t" ]; then
		shift
		# fake Bash 4 to disable "complete -o nospace". Instead
		# "compopt +-o nospace" is used in the code to toggle trailing
		# spaces. We don't support that, but leave trailing spaces on
		# all the time
		if [ "$1" = "__helm_compopt" ]; then
			echo builtin
			return 0
		fi
	fi
	type "$@"
}
__helm_compgen() {
	local completions w
	completions=( $(compgen "$@") ) || return $?
	# filter by given word as prefix
	while [[ "$1" = -* && "$1" != -- ]]; do
		shift
		shift
	done
	if [[ "$1" == -- ]]; then
		shift
	fi
	for w in "${completions[@]}"; do
		if [[ "${w}" = "$1"* ]]; then
			echo "${w}"
		fi
	done
}
__helm_compopt() {
	true # don't do anything. Not supported by bashcompinit in zsh
}
__helm_ltrim_colon_completions()
{
	if [[ "$1" == *:* && "$COMP_WORDBREAKS" == *:* ]]; then
		# Remove colon-word prefix from COMPREPLY items
		local colon_word=${1%${1##*:}}
		local i=${#COMPREPLY[*]}
		while [[ $((--i)) -ge 0 ]]; do
			COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
		done
	fi
}
__helm_get_comp_words_by_ref() {
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[${COMP_CWORD}-1]}"
	words=("${COMP_WORDS[@]}")
	cword=("${COMP_CWORD[@]}")
}
__helm_filedir() {
	local RET OLD_IFS w qw
	__debug "_filedir $@ cur=$cur"
	if [[ "$1" = \~* ]]; then
		# somehow does not work. Maybe, zsh does not call this at all
		eval echo "$1"
		return 0
	fi
	OLD_IFS="$IFS"
	IFS=$'\n'
	if [ "$1" = "-d" ]; then
		shift
		RET=( $(compgen -d) )
	else
		RET=( $(compgen -f) )
	fi
	IFS="$OLD_IFS"
	IFS="," __debug "RET=${RET[@]} len=${#RET[@]}"
	for w in ${RET[@]}; do
		if [[ ! "${w}" = "${cur}"* ]]; then
			continue
		fi
		if eval "[[ \"\${w}\" = *.$1 || -d \"\${w}\" ]]"; then
			qw="$(__helm_quote "${w}")"
			if [ -d "${w}" ]; then
				COMPREPLY+=("${qw}/")
			else
				COMPREPLY+=("${qw}")
			fi
		fi
	done
}
__helm_quote() {
	if [[ $1 == \'* || $1 == \"* ]]; then
		# Leave out first character
		printf %q "${1:1}"
	else
		printf %q "$1"
	fi
}
autoload -U +X bashcompinit && bashcompinit
# use word boundary patterns for BSD or GNU sed
LWORD='[[:<:]]'
RWORD='[[:>:]]'
if sed --help 2>&1 | grep -q 'GNU\|BusyBox'; then
	LWORD='\<'
	RWORD='\>'
fi
__helm_convert_bash_to_zsh() {
	sed \
	-e 's/declare -F/whence -w/' \
	-e 's/_get_comp_words_by_ref "\$@"/_get_comp_words_by_ref "\$*"/' \
	-e 's/local \([a-zA-Z0-9_]*\)=/local \1; \1=/' \
	-e 's/flags+=("\(--.*\)=")/flags+=("\1"); two_word_flags+=("\1")/' \
	-e 's/must_have_one_flag+=("\(--.*\)=")/must_have_one_flag+=("\1")/' \
	-e "s/${LWORD}_filedir${RWORD}/__helm_filedir/g" \
	-e "s/${LWORD}_get_comp_words_by_ref${RWORD}/__helm_get_comp_words_by_ref/g" \
	-e "s/${LWORD}__ltrim_colon_completions${RWORD}/__helm_ltrim_colon_completions/g" \
	-e "s/${LWORD}compgen${RWORD}/__helm_compgen/g" \
	-e "s/${LWORD}compopt${RWORD}/__helm_compopt/g" \
	-e "s/${LWORD}declare${RWORD}/builtin declare/g" \
	-e "s/\\\$(type${RWORD}/\$(__helm_type/g" \
	-e 's/aliashash\["\(.\{1,\}\)"\]/aliashash[\1]/g' \
	-e 's/FUNCNAME/funcstack/g' \
	<<'BASH_COMPLETION_EOF'
# bash completion for helm                                 -*- shell-script -*-

__helm_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__helm_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__helm_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__helm_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__helm_handle_reply()
{
    __helm_debug "${FUNCNAME[0]}"
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            COMPREPLY=( $(compgen -W "${allflags[*]}" -- "$cur") )
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __helm_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi
            return 0;
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __helm_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions=("${must_have_one_noun[@]}")
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    COMPREPLY=( $(compgen -W "${completions[*]}" -- "$cur") )

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        COMPREPLY=( $(compgen -W "${noun_aliases[*]}" -- "$cur") )
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
		if declare -F __helm_custom_func >/dev/null; then
			# try command name qualified custom func
			__helm_custom_func
		else
			# otherwise fall back to unqualified for compatibility
			declare -F __custom_func >/dev/null && __custom_func
		fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__helm_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__helm_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1
}

__helm_handle_flag()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __helm_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __helm_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __helm_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __helm_contains_word "${words[c]}" "${two_word_flags[@]}"; then
			  __helm_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__helm_handle_noun()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __helm_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __helm_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__helm_handle_command()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_helm_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __helm_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__helm_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __helm_handle_reply
        return
    fi
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __helm_handle_flag
    elif __helm_contains_word "${words[c]}" "${commands[@]}"; then
        __helm_handle_command
    elif [[ $c -eq 0 ]]; then
        __helm_handle_command
    elif __helm_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __helm_handle_command
        else
            __helm_handle_noun
        fi
    else
        __helm_handle_noun
    fi
    __helm_handle_word
}


__helm_override_flag_list=(--kubeconfig --kube-context --host --tiller-namespace --home)
__helm_override_flags()
{
    local ${__helm_override_flag_list[*]##*-} two_word_of of var
    for w in "${words[@]}"; do
        if [ -n "${two_word_of}" ]; then
            eval "${two_word_of##*-}=\"${two_word_of}=\${w}\""
            two_word_of=
            continue
        fi
        for of in "${__helm_override_flag_list[@]}"; do
            case "${w}" in
                ${of}=*)
                    eval "${of##*-}=\"${w}\""
                    ;;
                ${of})
                    two_word_of="${of}"
                    ;;
            esac
        done
    done
    for var in "${__helm_override_flag_list[@]##*-}"; do
        if eval "test -n \"\$${var}\""; then
            eval "echo \${${var}}"
        fi
    done
}

__helm_binary_name()
{
    local helm_binary
    helm_binary="${words[0]}"
    __helm_debug "${FUNCNAME[0]}: helm_binary is ${helm_binary}"
    echo ${helm_binary}
}

__helm_list_releases()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    local out filter
    # Use ^ to map from the start of the release name
    filter="^${words[c]}"
    # Use eval in case helm_binary_name or __helm_override_flags contains a variable (e.g., $HOME/bin/h2)
    if out=$(eval $(__helm_binary_name) list $(__helm_override_flags) -a -q -m 1000 ${filter} 2>/dev/null); then
        COMPREPLY=( $( compgen -W "${out[*]}" -- "$cur" ) )
    fi
}

__helm_list_repos()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    local out oflags
    oflags=$(__helm_override_flags)
    __helm_debug "${FUNCNAME[0]}: __helm_override_flags are ${oflags}"
    # Use eval in case helm_binary_name contains a variable (e.g., $HOME/bin/h2)
    if out=$(eval $(__helm_binary_name) repo list ${oflags} 2>/dev/null | tail +2 | cut -f1); then
        COMPREPLY=( $( compgen -W "${out[*]}" -- "$cur" ) )
    fi
}

__helm_list_plugins()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    local out oflags
    oflags=$(__helm_override_flags)
    __helm_debug "${FUNCNAME[0]}: __helm_override_flags are ${oflags}"
    # Use eval in case helm_binary_name contains a variable (e.g., $HOME/bin/h2)
    if out=$(eval $(__helm_binary_name) plugin list ${oflags} 2>/dev/null | tail +2 | cut -f1); then
        COMPREPLY=( $( compgen -W "${out[*]}" -- "$cur" ) )
    fi
}

__helm_custom_func()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[@] is ${words[@]}"
    case ${last_command} in
        helm_delete | helm_history | helm_status | helm_test |\
        helm_upgrade | helm_rollback | helm_get_*)
            __helm_list_releases
            return
            ;;
        helm_repo_remove | helm_repo_update)
            __helm_list_repos
            return
            ;;
        helm_plugin_remove | helm_plugin_update)
            __helm_list_plugins
            return
            ;;
        *)
            ;;
    esac
}

_helm_completion()
{
    last_command="helm_completion"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    must_have_one_noun+=("bash")
    must_have_one_noun+=("zsh")
    noun_aliases=()
}

_helm_create()
{
    last_command="helm_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--starter=")
    two_word_flags+=("--starter")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--starter=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_delete()
{
    last_command="helm_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--no-hooks")
    local_nonpersistent_flags+=("--no-hooks")
    flags+=("--purge")
    local_nonpersistent_flags+=("--purge")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_dependency_build()
{
    last_command="helm_dependency_build"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_dependency_list()
{
    last_command="helm_dependency_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_dependency_update()
{
    last_command="helm_dependency_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--skip-refresh")
    local_nonpersistent_flags+=("--skip-refresh")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_dependency()
{
    last_command="helm_dependency"

    command_aliases=()

    commands=()
    commands+=("build")
    commands+=("list")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("update")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("up")
        aliashash["up"]="update"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_fetch()
{
    last_command="helm_fetch"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--destination=")
    two_word_flags+=("--destination")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--destination=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--prov")
    local_nonpersistent_flags+=("--prov")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--untar")
    local_nonpersistent_flags+=("--untar")
    flags+=("--untardir=")
    two_word_flags+=("--untardir")
    local_nonpersistent_flags+=("--untardir=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_get_hooks()
{
    last_command="helm_get_hooks"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_get_manifest()
{
    last_command="helm_get_manifest"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_get_notes()
{
    last_command="helm_get_notes"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_get_values()
{
    last_command="helm_get_values"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    flags+=("--output=")
    two_word_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_get()
{
    last_command="helm_get"

    command_aliases=()

    commands=()
    commands+=("hooks")
    commands+=("manifest")
    commands+=("notes")
    commands+=("values")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--template=")
    two_word_flags+=("--template")
    local_nonpersistent_flags+=("--template=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_history()
{
    last_command="helm_history"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--col-width=")
    two_word_flags+=("--col-width")
    local_nonpersistent_flags+=("--col-width=")
    flags+=("--max=")
    two_word_flags+=("--max")
    local_nonpersistent_flags+=("--max=")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_home()
{
    last_command="helm_home"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_init()
{
    last_command="helm_init"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--automount-service-account-token")
    local_nonpersistent_flags+=("--automount-service-account-token")
    flags+=("--canary-image")
    local_nonpersistent_flags+=("--canary-image")
    flags+=("--client-only")
    flags+=("-c")
    local_nonpersistent_flags+=("--client-only")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--force-upgrade")
    local_nonpersistent_flags+=("--force-upgrade")
    flags+=("--history-max=")
    two_word_flags+=("--history-max")
    local_nonpersistent_flags+=("--history-max=")
    flags+=("--local-repo-url=")
    two_word_flags+=("--local-repo-url")
    local_nonpersistent_flags+=("--local-repo-url=")
    flags+=("--net-host")
    local_nonpersistent_flags+=("--net-host")
    flags+=("--node-selectors=")
    two_word_flags+=("--node-selectors")
    local_nonpersistent_flags+=("--node-selectors=")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--override=")
    two_word_flags+=("--override")
    local_nonpersistent_flags+=("--override=")
    flags+=("--replicas=")
    two_word_flags+=("--replicas")
    local_nonpersistent_flags+=("--replicas=")
    flags+=("--service-account=")
    two_word_flags+=("--service-account")
    local_nonpersistent_flags+=("--service-account=")
    flags+=("--skip-refresh")
    local_nonpersistent_flags+=("--skip-refresh")
    flags+=("--stable-repo-url=")
    two_word_flags+=("--stable-repo-url")
    local_nonpersistent_flags+=("--stable-repo-url=")
    flags+=("--tiller-image=")
    two_word_flags+=("--tiller-image")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--tiller-image=")
    flags+=("--tiller-tls")
    local_nonpersistent_flags+=("--tiller-tls")
    flags+=("--tiller-tls-cert=")
    two_word_flags+=("--tiller-tls-cert")
    local_nonpersistent_flags+=("--tiller-tls-cert=")
    flags+=("--tiller-tls-hostname=")
    two_word_flags+=("--tiller-tls-hostname")
    local_nonpersistent_flags+=("--tiller-tls-hostname=")
    flags+=("--tiller-tls-key=")
    two_word_flags+=("--tiller-tls-key")
    local_nonpersistent_flags+=("--tiller-tls-key=")
    flags+=("--tiller-tls-verify")
    local_nonpersistent_flags+=("--tiller-tls-verify")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--upgrade")
    local_nonpersistent_flags+=("--upgrade")
    flags+=("--wait")
    local_nonpersistent_flags+=("--wait")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_inspect_chart()
{
    last_command="helm_inspect_chart"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_inspect_readme()
{
    last_command="helm_inspect_readme"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_inspect_values()
{
    last_command="helm_inspect_values"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_inspect()
{
    last_command="helm_inspect"

    command_aliases=()

    commands=()
    commands+=("chart")
    commands+=("readme")
    commands+=("values")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_install()
{
    last_command="helm_install"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--atomic")
    local_nonpersistent_flags+=("--atomic")
    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--dep-up")
    local_nonpersistent_flags+=("--dep-up")
    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--name-template=")
    two_word_flags+=("--name-template")
    local_nonpersistent_flags+=("--name-template=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--no-crd-hook")
    local_nonpersistent_flags+=("--no-crd-hook")
    flags+=("--no-hooks")
    local_nonpersistent_flags+=("--no-hooks")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--render-subchart-notes")
    local_nonpersistent_flags+=("--render-subchart-notes")
    flags+=("--replace")
    local_nonpersistent_flags+=("--replace")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--set=")
    two_word_flags+=("--set")
    local_nonpersistent_flags+=("--set=")
    flags+=("--set-file=")
    two_word_flags+=("--set-file")
    local_nonpersistent_flags+=("--set-file=")
    flags+=("--set-string=")
    two_word_flags+=("--set-string")
    local_nonpersistent_flags+=("--set-string=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--values=")
    two_word_flags+=("--values")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--values=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--wait")
    local_nonpersistent_flags+=("--wait")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_lint()
{
    last_command="helm_lint"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--set=")
    two_word_flags+=("--set")
    local_nonpersistent_flags+=("--set=")
    flags+=("--set-file=")
    two_word_flags+=("--set-file")
    local_nonpersistent_flags+=("--set-file=")
    flags+=("--set-string=")
    two_word_flags+=("--set-string")
    local_nonpersistent_flags+=("--set-string=")
    flags+=("--strict")
    local_nonpersistent_flags+=("--strict")
    flags+=("--values=")
    two_word_flags+=("--values")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--values=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_list()
{
    last_command="helm_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    flags+=("--chart-name")
    flags+=("-c")
    local_nonpersistent_flags+=("--chart-name")
    flags+=("--col-width=")
    two_word_flags+=("--col-width")
    local_nonpersistent_flags+=("--col-width=")
    flags+=("--date")
    flags+=("-d")
    local_nonpersistent_flags+=("--date")
    flags+=("--deleted")
    local_nonpersistent_flags+=("--deleted")
    flags+=("--deleting")
    local_nonpersistent_flags+=("--deleting")
    flags+=("--deployed")
    local_nonpersistent_flags+=("--deployed")
    flags+=("--failed")
    local_nonpersistent_flags+=("--failed")
    flags+=("--max=")
    two_word_flags+=("--max")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--max=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--offset=")
    two_word_flags+=("--offset")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--offset=")
    flags+=("--output=")
    two_word_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    flags+=("--pending")
    local_nonpersistent_flags+=("--pending")
    flags+=("--reverse")
    flags+=("-r")
    local_nonpersistent_flags+=("--reverse")
    flags+=("--short")
    flags+=("-q")
    local_nonpersistent_flags+=("--short")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_package()
{
    last_command="helm_package"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--app-version=")
    two_word_flags+=("--app-version")
    local_nonpersistent_flags+=("--app-version=")
    flags+=("--dependency-update")
    flags+=("-u")
    local_nonpersistent_flags+=("--dependency-update")
    flags+=("--destination=")
    two_word_flags+=("--destination")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--destination=")
    flags+=("--key=")
    two_word_flags+=("--key")
    local_nonpersistent_flags+=("--key=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--save")
    local_nonpersistent_flags+=("--save")
    flags+=("--sign")
    local_nonpersistent_flags+=("--sign")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_plugin_install()
{
    last_command="helm_plugin_install"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_plugin_list()
{
    last_command="helm_plugin_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_plugin_remove()
{
    last_command="helm_plugin_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_plugin_update()
{
    last_command="helm_plugin_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_plugin()
{
    last_command="helm_plugin"

    command_aliases=()

    commands=()
    commands+=("install")
    commands+=("list")
    commands+=("remove")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo_add()
{
    last_command="helm_repo_add"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--no-update")
    local_nonpersistent_flags+=("--no-update")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo_index()
{
    last_command="helm_repo_index"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--merge=")
    two_word_flags+=("--merge")
    local_nonpersistent_flags+=("--merge=")
    flags+=("--url=")
    two_word_flags+=("--url")
    local_nonpersistent_flags+=("--url=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo_list()
{
    last_command="helm_repo_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo_remove()
{
    last_command="helm_repo_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo_update()
{
    last_command="helm_repo_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--strict")
    local_nonpersistent_flags+=("--strict")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo()
{
    last_command="helm_repo"

    command_aliases=()

    commands=()
    commands+=("add")
    commands+=("index")
    commands+=("list")
    commands+=("remove")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("rm")
        aliashash["rm"]="remove"
    fi
    commands+=("update")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("up")
        aliashash["up"]="update"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_reset()
{
    last_command="helm_reset"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    flags+=("--remove-helm-home")
    local_nonpersistent_flags+=("--remove-helm-home")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_rollback()
{
    last_command="helm_rollback"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cleanup-on-fail")
    local_nonpersistent_flags+=("--cleanup-on-fail")
    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--no-hooks")
    local_nonpersistent_flags+=("--no-hooks")
    flags+=("--recreate-pods")
    local_nonpersistent_flags+=("--recreate-pods")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--wait")
    local_nonpersistent_flags+=("--wait")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_search()
{
    last_command="helm_search"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--col-width=")
    two_word_flags+=("--col-width")
    local_nonpersistent_flags+=("--col-width=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--regexp")
    flags+=("-r")
    local_nonpersistent_flags+=("--regexp")
    flags+=("--version=")
    two_word_flags+=("--version")
    two_word_flags+=("-v")
    local_nonpersistent_flags+=("--version=")
    flags+=("--versions")
    flags+=("-l")
    local_nonpersistent_flags+=("--versions")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_serve()
{
    last_command="helm_serve"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--address=")
    two_word_flags+=("--address")
    local_nonpersistent_flags+=("--address=")
    flags+=("--repo-path=")
    two_word_flags+=("--repo-path")
    local_nonpersistent_flags+=("--repo-path=")
    flags+=("--url=")
    two_word_flags+=("--url")
    local_nonpersistent_flags+=("--url=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_status()
{
    last_command="helm_status"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_template()
{
    last_command="helm_template"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-versions=")
    two_word_flags+=("--api-versions")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--api-versions=")
    flags+=("--execute=")
    two_word_flags+=("--execute")
    two_word_flags+=("-x")
    local_nonpersistent_flags+=("--execute=")
    flags+=("--is-upgrade")
    local_nonpersistent_flags+=("--is-upgrade")
    flags+=("--kube-version=")
    two_word_flags+=("--kube-version")
    local_nonpersistent_flags+=("--kube-version=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--name-template=")
    two_word_flags+=("--name-template")
    local_nonpersistent_flags+=("--name-template=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--notes")
    local_nonpersistent_flags+=("--notes")
    flags+=("--output-dir=")
    two_word_flags+=("--output-dir")
    local_nonpersistent_flags+=("--output-dir=")
    flags+=("--set=")
    two_word_flags+=("--set")
    local_nonpersistent_flags+=("--set=")
    flags+=("--set-file=")
    two_word_flags+=("--set-file")
    local_nonpersistent_flags+=("--set-file=")
    flags+=("--set-string=")
    two_word_flags+=("--set-string")
    local_nonpersistent_flags+=("--set-string=")
    flags+=("--values=")
    two_word_flags+=("--values")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--values=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_test()
{
    last_command="helm_test"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cleanup")
    local_nonpersistent_flags+=("--cleanup")
    flags+=("--logs")
    local_nonpersistent_flags+=("--logs")
    flags+=("--max=")
    two_word_flags+=("--max")
    local_nonpersistent_flags+=("--max=")
    flags+=("--parallel")
    local_nonpersistent_flags+=("--parallel")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_upgrade()
{
    last_command="helm_upgrade"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--atomic")
    local_nonpersistent_flags+=("--atomic")
    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--cleanup-on-fail")
    local_nonpersistent_flags+=("--cleanup-on-fail")
    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--install")
    flags+=("-i")
    local_nonpersistent_flags+=("--install")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--no-hooks")
    local_nonpersistent_flags+=("--no-hooks")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--recreate-pods")
    local_nonpersistent_flags+=("--recreate-pods")
    flags+=("--render-subchart-notes")
    local_nonpersistent_flags+=("--render-subchart-notes")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--reset-values")
    local_nonpersistent_flags+=("--reset-values")
    flags+=("--reuse-values")
    local_nonpersistent_flags+=("--reuse-values")
    flags+=("--set=")
    two_word_flags+=("--set")
    local_nonpersistent_flags+=("--set=")
    flags+=("--set-file=")
    two_word_flags+=("--set-file")
    local_nonpersistent_flags+=("--set-file=")
    flags+=("--set-string=")
    two_word_flags+=("--set-string")
    local_nonpersistent_flags+=("--set-string=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--values=")
    two_word_flags+=("--values")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--values=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--wait")
    local_nonpersistent_flags+=("--wait")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_verify()
{
    last_command="helm_verify"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_version()
{
    last_command="helm_version"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--client")
    flags+=("-c")
    local_nonpersistent_flags+=("--client")
    flags+=("--server")
    flags+=("-s")
    local_nonpersistent_flags+=("--server")
    flags+=("--short")
    local_nonpersistent_flags+=("--short")
    flags+=("--template=")
    two_word_flags+=("--template")
    local_nonpersistent_flags+=("--template=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_root_command()
{
    last_command="helm"

    command_aliases=()

    commands=()
    commands+=("completion")
    commands+=("create")
    commands+=("delete")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("del")
        aliashash["del"]="delete"
    fi
    commands+=("dependency")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("dep")
        aliashash["dep"]="dependency"
        command_aliases+=("dependencies")
        aliashash["dependencies"]="dependency"
    fi
    commands+=("fetch")
    commands+=("get")
    commands+=("history")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("hist")
        aliashash["hist"]="history"
    fi
    commands+=("home")
    commands+=("init")
    commands+=("inspect")
    commands+=("install")
    commands+=("lint")
    commands+=("list")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("package")
    commands+=("plugin")
    commands+=("repo")
    commands+=("reset")
    commands+=("rollback")
    commands+=("search")
    commands+=("serve")
    commands+=("status")
    commands+=("template")
    commands+=("test")
    commands+=("upgrade")
    commands+=("verify")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_helm()
{
    local cur prev words cword
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __helm_init_completion -n "=" || return
    fi

    local c=0
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("helm")
    local must_have_one_flag=()
    local must_have_one_noun=()
    local last_command
    local nouns=()

    __helm_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_helm helm
else
    complete -o default -o nospace -F __start_helm helm
fi

# ex: ts=4 sw=4 et filetype=sh

BASH_COMPLETION_EOF
}
__helm_bash_source <(__helm_convert_bash_to_zsh)
# peco-completion-file

zstyle ':completion:*:*:peco:*:*' format '%BCompleting %d%b'

_peco_completion()
{
	_arguments \
		'-h, --help[show this help message and exit]' \
		'--tty[path to the TTY (usually, the value of $TTY)]' \
		'--query[initial value for query]' \
		'--rcfile[path to the settings file]' \
		'--no-ignore-case[start in case-sensitive-mode (DEPRECATED)]' \
		'--version[print the version and exit]' \
		'-b, --buffer-size[number of lines to keep in search buffer]' \
		'--null[expect NUL (\0) as separator for target/output]' \
		'--initial-index[position of the initial index of the selection (0 base)]' \
		'--initial-matcher[specify the default matcher]' \
		'--prompt[specify the prompt string]' \
		'--layout[layout to be used "top-down"(default) or "bottom-up"]' \
 		'*:file:_files'
}

compdef _peco_completion peco
_sls_templates() {
  _values \
    'VALID TEMPLATES' \
    'aws-nodejs' \
    'aws-python' \
    'aws-java-maven' \
    'aws-java-gradle'
}

_sls_regions() {
  _values \
    'VALID REGIONS' \
    'us-east-1' \
    'us-west-1' \
    'us-west-2' \
    'eu-west-1' \
    'ap-southeast-1' \
    'ap-northeast-1' \
    'ap-southeast-2' \
    'sa-east-1'
}

_sls_invoke_types() {
  _values \
    'VALID INVOKE TYPES' \
    'RequestResponse' \
    'Event' \
    'DryRun'
}

_sls_json_files() {
  local json_files
  json_files=("${(@f)$(find . -type f -name "*.json" \
    -not -path "./node_modules/*" \
    -not -path "./.serverless/*" \
    -not -name "package.json")}")
  _values 'JSON FILES FOUND' $json_files
}

_sls_functions() {
  # parse the functions from the serverless.yaml
  # with a whole lot of aws/grep/sed/zsh magic
  local functions
  functions=("${(@f)$(awk '/^functions/{p=1;print;next} p&&/^(resources|package|provider|plugins|service)/{p=0};p' serverless.yml \
    | grep -e "^  \w\+:" \
    | sed 's/ \+//' \
    | sed 's/:\+//')}")
  _values 'VALID FUNCTIONS' $functions
}

_sls () {
  typeset -A opt_args

  _arguments -C \
  '1:cmd:->cmds' \
  '*::arg:->args'

  case "$state" in
    (cmds)
      local commands
      commands=(
        'create:Create new Serverless Service.'
        'deploy:Deploy Service.'
        'info:Displays information about the service.'
        'invoke:Invokes a deployed function.'
        'logs:Outputs the logs of a deployed function.'
        'remove:Remove resources.'
        'tracking:Enable or disable usage tracking.'
      )

      _describe -t commands 'command' commands
      return 0
    ;;
    (args)
      case $line[1] in
        (create)
          _sls_create
        ;;
        (deploy)
          _sls_deploy
        ;;
        (info)
          _sls_info
        ;;
        (invoke)
          _sls_invoke
        ;;
        (logs)
          _sls_logs
        ;;
        (remove)
          _sls_remove
        ;;
        (tracking)
          _sls_tracking
        ;;
      esac;
    ;;
  esac;

  return 1
}

_sls_create(){
  _arguments -s \
    -t'[Template for the service (required)]:sls_templates:_sls_templates' \
    -p'[The path where the service should be created]'
    return 0
}

_sls_deploy(){
  if [[ $line[2] == "function" ]]; then
    # TODO: this doesn't seem to work for the subcommand
    _arguments -s \
      -f'[Name of the function (required)]:sls_functions:_sls_functions' \
      -r'[Region of the service]:sls_regions:_sls_regions' \
      -s'[Stage of the function]'
      return 0
  else
    _arguments -s \
      -n'[Build artifacts without deploying]' \
      -r'[Region of the service]:sls_regions:_sls_regions' \
      -s'[Stage of the service]' \
      -v'[Show all stack events during deployment]'

    local subcommands
    subcommands=(
      'function:Deploys a single function from the service.'
      )
    _describe -t commands 'deploy subcommands' subcommands
    return 0
  fi
  return 1
}

_sls_info() {
  _arguments -s \
    -r'[Region of the service]:sls_regions:_sls_regions' \
    -s'[Stage of the service]'
    return 0
}

_sls_invoke() {
  _arguments -s \
    -f'[The function name (required)]:sls_functions:_sls_functions' \
    -l'[Trigger logging data output]' \
    -p'[Path to JSON file holding input data]:sls_json_files:_sls_json_files' \
    -r'[Region of the service]:sls_regions:_sls_regions' \
    -s'[Stage of the function]' \
    -t'[Type of invocation]:sls_invoke_types:_sls_invoke_types'
    return 0
}

_sls_logs() {
  _arguments -s \
    -f'[The function name (required)]:sls_functions:_sls_functions' \
    --filter'[A filter pattern]' \
    -i'[Tail polling interval in milliseconds. Default: 1000]' \
    -r'[Region of the service]:sls_regions:_sls_regions' \
    -s'[Stage of the function]' \
    --startTime'[Logs before this time will not be displayed]' \
    -t'[Tail the log output]'
    return 0
}

_sls_remove() {
  _arguments -s \
    -r'[Region of the service]:sls_regions:_sls_regions' \
    -s'[Stage of the function]' \
    -v'[Show all stack events during deployment]'
    return 0
}

_sls_tracking() {
  _arguments -s \
    -d'[Disable tracking]' \
    -e'[Enable tracking]'
    return 0
}

compdef _sls sls serverless
zstyle ':completion:*:*:task:*' verbose yes
zstyle ':completion:*:*:task:*:descriptions' format '%U%B%d%b%u'

zstyle ':completion:*:*:task:*' group-name ''

alias t=task
compdef _task t=task
source <(kubectl completion zsh)


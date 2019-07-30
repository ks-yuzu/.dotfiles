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
## plenv
# PERL_LOCAL_LIB="$HOME/perl5"
# export PATH=${PERL_LOCAL_LIB}/bin:$PATH
# export PERL5LIB=${PERL_LOCAL_LIB}/lib/perl5:$PERL5LIB

if [ -x "`which plenv`" ]; then
  export PLENV_VERSION=$(plenv version | awk '{print $1}')
  # export PERL_CPANM_OPT="--local-lib=${PERL_LOCAL_LIB}"
  export PATH=${PLENV_ROOT}/bin:$PATH
  export PERL5LIB=${PLENV_ROOT}/versions/${PLENV_VERSION}/lib/perl5:$PERL5LIB
fi

## node
export PATH=$HOME/.nodebrew/current/bin:$PATH

## cabal
# export PATH=$HOME/.cabal/bin:$PATH

## java
# export TOMCAT_HOME=/usr/share/tomcat6
# export CATALINA_HOME=/usr/share/tomcat6
# export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
# export PATH=$PATH:$JAVA_HOME/bin
# export CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
# export CLASSPATH=$CLASSPATH:$CATALINA_HOME/common/lib:$CATALINA_HOME/common/lib/servlet-api.jar
# export CLASSPATH=$CLASSPATH:/usr/share/java/mysql-connector-java-5.1.28.jar # jdbc

## others
# export PATH=$PATH:$HOME/.local/lib/python2.7/site-packages/powerline
# export PATH=$PATH:/opt/ibm/ILOG/CPLEX_Studio1261/cplex/bin/x86-64_linux
export PATH=$HOME/bin:$PATH
export PATH=$HOME/opt:$PATH
# export PATH=$HOME/bin/processing/:$PATH

autoload -Uz add-zsh-hook

## tmux info disp
function disp-tmux-info()
{
    if [ $(perl -e "print '$TERM' =~ /screen/ ? 1 : 0") -eq 0 ] && return

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
    grep screen <<<$TERM > /dev/null || return

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
    grep screen <<<$TERM > /dev/null || return
    echo -n "["
    echo -n $(disp-tmux-info-mini)
    echo -n "] "
}




## prompt
function update-prompt()
{
    local name="%F{green}%n@%m%f "
    local tmuxinfo="%F{magenta}$(disp-tmux-info-for-prompt)%f"
    local cdir="%F{yellow}%~%f "
    local endl=$'\n'
    local mark="%B%(?,%F{green},%F{red})%(!,#,>)%f%b "


    local face=''
    local info=''
;    if [ -z $STS_EXPIRATION_UNIXTIME ]; then
        face='(-ω-)zzz'
    else
        local lefttime="$(($STS_EXPIRATION_UNIXTIME - $(date +%s)))"

        if [ $lefttime -gt 0 ]; then
            face="('ω')"
            info=" $STS_ALIAS_SHORT($lefttime)"
        else
            face='(>_<)'
            info=" $STS_ALIAS_SHORT(%F{red}expired%f)"
        fi
    fi

    local sts="sts:${face}${info} "

    PROMPT="${name}${tmuxinfo}${sts}${cdir}${endl}${mark}"
}

add-zsh-hook precmd update-prompt


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
    local ahead_count=$(test ! -z "$current_branch" && git rev-list --count origin/${current_branch}..${current_branch} 2>/dev/null | perl -ne '/(\d+)/ and $1 and print " +$1"')

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

RPROMPT='$(rprompt)'

## period
function show-time()
{
    echo ""
    LC_ALL=c date | perl -pe 's/^(.*)$/(\1)/'
}

PERIOD=30
add-zsh-hook periodic show-time


## rev-prompt
# autoload -Uz vcs_info
# autoload -Uz colors
# colors
# autoload -Uz add-zsh-hook
# setopt prompt_subst
# zstyle ':vcs_info:*' enable git
# zstyle ':vcs_info:git:*' check-for-changes true
# zstyle ':vcs_info:git:*' stagedstr "%{$fg[yellow]%}+"
# zstyle ':vcs_info:git:*' unstagedstr "%{$fg[red]%}!"
# #zstyle ':vcs_info:*'     formats       "%{$fg[green]%}%c%u[%b]%{$reset_color%}"
# #zstyle ':vcs_info:*'     actionformats '[%b|%a]'
# #precmd () { vcs_info }
# #RPROMPT='${vcs_info_msg_0_}'


# zstyle ':vcs_info:git:stagedstr:*:' S
# zstyle ':vcs_info:git:unstagedstr:*' U
# zstyle ':vcs_info:*' formats "%{${fg[green]}%}[%b] %{${fg_bold[red]}%}%c%u%{${reset_color}%}"

#  PROMPT="$PROMPT_USERHOST $PROMPT_TIME $vcs_info_msg_0_ $PROMPT_STATUS"

# update_vcs_info () {
#     vcs_info
#     RPROMPT="$vcs_info_msg_0_"
# }
# add-zsh-hook precmd update_vcs_info  # precmd フックへの登録






# autoload -Uz VCS_INFO_get_data_git; VCS_INFO_get_data_git 2> /dev/null

# function rprompt-git-current-branch {
#         local name st color gitdir action
#         if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
#                 return
#         fi

#         name=`git rev-parse --abbrev-ref=loose HEAD 2> /dev/null`
#         if [[ -z $name ]]; then
#                 return
#         fi

#         gitdir=`git rev-parse --git-dir 2> /dev/null`
#         action=`VCS_INFO_git_getaction "$gitdir"` && action="($action)"

# 		if [[ -e "$gitdir/rprompt-nostatus" ]]; then
# 		   echo "$name$action "
# 		   		return
# 				fi

#         st=`git status 2> /dev/null`
# 		if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
# 		   color=%F{green}
# 		   elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
# 		   		color=%F{yellow}
# 				elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
#                 color=%B%F{red}
#         else
#                 color=%F{red}
#         fi

#         echo "$color$name$action%f%b"
# }

function get-path-from-git-root
{
	git rev-parse --show-prefix 2> /dev/null
}


# remake prompt-meswhen showing prompt
# setopt prompt_subst

# RPROMPT='[`rprompt-git-current-branch``relative-path`]' #%~]'
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

alias ssh='perl -e '\''$args = join "_", (grep { $_ !~ /^\-/ } @ARGV); $ts = qx/date --iso-8601=seconds/; chomp $ts; exec "script ~/works/ssh-log/ssh-${ts}-${args}.log /usr/bin/ssh @ARGV"'\'''

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

export LYNX_CFG=~/.lynx
export EDITOR='emacsclient -t'
export CVSEDITOR="${EDITOR}"
export SVN_EDITOR="${EDITOR}"
export GIT_EDITOR="${EDITOR}"

# less command
export VISUAL='emacsclient -t'
export LESS='-N -M -R'

export FZF_DEFAULT_OPTS="--cycle --no-mouse --reverse --prompt='QUERY> ' --color=16"
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
        local dir=$(cdr -l | peco | awk '{print $2}')
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

add-zsh-hook precmd rename_tmux_window
# peco の存在チェック
if [ ! ${+commands[peco]} ]; then
    return
fi


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
                 peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
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
            fullpath=$(find `pwd`/$1 -maxdepth 1 -mindepth 1 | peco)
        fi
    else
        fullpath=$(find `pwd` -maxdepth 1 -mindepth 1 | peco)
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
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ssh
bindkey '^\' peco-ssh


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
        echo ''
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
    git checkout $(git branch -a | peco | sed -e 's/^..//g' -e '/->/d' -e 's|remotes/origin/||g' | awk '!a[$0]++')
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
    git commit -v
    zle reset-prompt
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

if [[ -n "${REMOTEHOST}${SSH_CONNECTION}" && -z "$TMUX" && -z "$STY" ]] && type tmux >/dev/null 2>&1; then
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
    if tmux has-session && tmux list-sessions; then
        option="attach"
    fi
    tmux $option && confirm "exit?" && exit
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
# commnads for kwansei

function kwansei-z()
{
    KWANSEI_Z_MOUNT_POINT_LOCAL='/mnt/kwansei-z'
    
    # Make a mount point directory
    if [ ! -d $KWANSEI_Z_MOUNT_POINT_LOCAL ]; then
        sudo mkdir $KWANSEI_Z_MOUNT_POINT_LOCAL
        echo "Made a directory '$KWANSEI_Z_MOUNT_POINT_LOCAL'."
    fi

    echo 'test';
    
    # mount
	if [ $(mount -v | grep $KWANSEI_Z_MOUNT_POINT_LOCAL | wc -l)  -eq '0' ]; then
        sudo mount /mnt/kwansei-z
    else
        echo 'already mounted'
	fi

	cd $KWANSEI_Z_MOUNT_POINT_LOCAL
}


function kscproxy()
{
	export http_proxy="http://proxy.ksc.kwansei.ac.jp:8080"
	export https_proxy="https://proxy.ksc.kwansei.ac.jp:8080"
}
# commnads for lab

##### scripts for vpn #####
alias labvpn='sudo /usr/sbin/openvpn /etc/openvpn/client.ovpn &'


##### scripts for gitlab #####
function gitlab-open
{
    if [ $(ps aux | grep ssh | grep 192.218.172.56:80 | wc -l) -eq 0 ]; then
        ssh -fN -L9999:192.218.172.56:80 lab-g56
    fi

    firefox localhost:9999
}

function gitlab-close
{
    local pid=$(ps -aux | grep ssh | grep 192.218.172.56:80 | peco | awk '{print $2}' )
    if [ $pid != "" ]; then
       kill $pid && echo killed $pid
    fi
}


##### scripts for nas #####
export LAB_NAS_MOUNT_POINT_LOCAL='/mnt/labnas'

function inas()
{
    # Make a mount point directory
    if [ ! -d $LAB_NAS_MOUNT_POINT_LOCAL ]; then
            sudo mkdir $LAB_NAS_MOUNT_POINT_LOCAL
            echo "Made a directory '$LAB_NAS_MOUNT_POINT_LOCAL'."
    fi

    # mount
	if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_LOCAL | wc -l)  -eq '0' ];then
        # Linux Kernel 4.13 から SMB 3.0 がデフォルトCIFSになっている.
        # SMB 3.0 では NAS に接続できなかったため, SMB 1.0 で接続する.
		sudo mount -t cifs //192.168.0.16/disk1 $LAB_NAS_MOUNT_POINT_LOCAL \
			 -o iocharset=utf8,username=user,password=pass,file_mode=0755,dir_mode=0755,uid=$(id -u),gid=$(id -g),vers=1.0
	fi

	cd $LAB_NAS_MOUNT_POINT_LOCAL
}

function uinas()
{
	if [ $(pwd | grep $LAB_NAS_MOUNT_POINT_LOCAL | wc -l)  -eq '1' ];then
		cd > /dev/null
	fi

    if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_LOCAL | wc -l)  -ge '1' ];then
	    sudo umount $LAB_NAS_MOUNT_POINT_LOCAL
    fi

    if [ -d $LAB_NAS_MOUNT_POINT_LOCAL ] && sudo rmdir $LAB_NAS_MOUNT_POINT_LOCAL
}


##### scripts for nas with sshfs #####
export SSH_USER='yuzu'
export LAB_NAS_MOUNT_POINT_SSH='/mnt/ssh-labnas'
export LAB_SERVER10_KEY_PATH="$HOME/.ssh/lab/id_ed25519_excomputer"
export LAB_SERVER_IP='192.218.172.58'
#export LAB_SERVER_IP='192.168.0.10'

function sshinas()
{
    if [ ! -d $LAB_NAS_MOUNT_POINT_SSH ]; then
        sudo mkdir $LAB_NAS_MOUNT_POINT_SSH
        echo "Made a mount point directory '$LAB_NAS_MOUNT_POINT_SSH'"
    fi
    
    if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_SSH | wc -l)  -eq '0' ];then
        sudo sshfs \
             ${SSH_USER}@${LAB_SERVER_IP}:${LAB_NAS_MOUNT_POINT_LOCAL} \
             $LAB_NAS_MOUNT_POINT_SSH \
             -o uid=$(id -u),gid=$(id -g),allow_other,IdentityFile=$LAB_SERVER10_KEY_PATH
    fi
    cd $LAB_NAS_MOUNT_POINT_SSH
}

function usshinas()
{
	if [ $(pwd | grep $LAB_NAS_MOUNT_POINT_SSH | wc -l)  -eq '1' ];then
		cd > /dev/null
	fi

    if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_LOCAL | wc -l)  -ge '1' ];then
	    sudo umount $LAB_NAS_MOUNT_POINT_SSH
    fi

    if [ -d $LAB_NAS_MOUNT_POINT_SSH ] && sudo rmdir $LAB_NAS_MOUNT_POINT_SSH
}
# acap.pl の存在チェック
if [ ! ${+commands[acap.pl]} ]; then
    return
fi



# vivado
export PATH=${HOME}/opt/Vivado/2016.4/bin:$PATH

# acap-dir
export ACAP_DIR="$HOME/tools/acap"
export MIPSLITE_DIR="$HOME/tools/mipslite"
export MIPS_ELF_GCC_LIB_DIR="$HOME/tools/acap/lib"

# acap
export PATH=${ACAP_DIR}/bin:$PATH
export LIBDIR=${ACAP_DIR}/ccaplib 
export PATH=${MIPS_ELF_GCC_LIB_DIR}/mips-elf/gcc-4.8.2/bin:$PATH
export LD_LIBRARY_PATH=${MIPS_ELF_GCC_LIB_DIR}/mpc-1.0.2/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${MIPS_ELF_GCC_LIB_DIR}/mpfr-3.1.2/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${MIPS_ELF_GCC_LIB_DIR}/gmp-6.0.0/lib:${LD_LIBRARY_PATH}
export SOFT_FP_DIR=${MIPS_ELF_GCC_LIB_DIR}/gcc-4.8.2/build/mips-elf/soft-float/el/libgcc

# alias
alias acap='acap.pl -Z1 -Dall --remain-linked-object -l synthesized/ --enable-inlining'
alias ise='ise >/dev/null 2>&1 &'
alias vivado='vivado >/dev/null 2>&1 &'


function clean-acap {
    local dir='.'
    if [ -d synthesized ]; then
        dir='synthesized'
    fi
    
    rm -f $dir/*.o
    rm -f $dir/*.s
    rm -f $dir/*.0
    rm -f $dir/user.obj
    rm -f $dir/*.out
    rm -f $dir/*.dmem
    rm -f $dir/*.txt
    rm -f $dir/*_i.mem
    rm -f $dir/*_d.mem
    rm -f $dir/*.low
    rm -f $dir/*.dfa
    rm -f $dir/*.sch
    rm -f $dir/*.bnd
    rm -f $dir/*.stl
    rm -f $dir/*.rtl
    rm -f $dir/*.v
}
# WSL 上のみ実行
if [[ ! `uname -a` =~ "Linux.*Microsoft" ]]; then
    return
fi

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

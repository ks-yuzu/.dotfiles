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
    CURSOR="$#BUFFER"
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
    # zle clear-screen
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
    local recipe=$(grep -P '^\S+:' Makefile | sed 's/:.*$//g' | peco)
    if [ -n "$recipe" ]; then
        BUFFER="make ${recipe}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-make
bindkey '^[m' peco-make


# peco ghq
function  peco-ghq() {
  local selected_dir=$(ghq list -p | peco --prompt='repo> ' --query "$LBUFFER")

  if [ -n "$selected_dir" ]; then
    BUFFER=" cd ${selected_dir}"
    zle accept-line
  fi
}
zle -N peco-ghq
bindkey '^[g' $_

function peco-ghq-clone() {
}


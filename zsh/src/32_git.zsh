## git status
function __git-status()
{
    BUFFER=' git status -sb'
    zle accept-line
}
zle -N __git-status && bindkey "^gs" $_


## git diff
function __peco-git-diff()
{
    #local GIT_ROOT="$(pwd)$(perl -e "print '/..' x $(get-git-dir-depth)")"
    local GIT_ROOT="$(perl -e "print '../' x $(get-git-dir-depth)")"

    if [ -z "$(git status --porcelain)" ]; then
      echo ''
      BUFFER=' git status'
    else
      local SELECTED_FILE="$(git status --porcelain | \
                               grep '^ *M' | \
                               peco --query "$LBUFFER" | \
                               awk -F ' ' '{print $NF}')"
      [ -n "$SELECTED_FILE" ] || return

      BUFFER=" (builtin cd '$GIT_ROOT' && git diff $(echo "$SELECTED_FILE" | tr '\n' ' '))"
    fi

    zle accept-line
}
zle -N __peco-git-diff && bindkey "^gd" $_


## git diff --cached
function __git-diff-cached() {
    BUFFER=' git diff --cached'
    zle accept-line
}
zle -N __git-diff-cached && bindkey "^gD" $_


## git add
function __peco-git-add()
{
    local SELECTED_FILE="$(git status --short | \
                             peco --query "$LBUFFER" | \
                             awk -F ' ' '{print $NF}')"
    [ -n "$SELECTED_FILE" ] || return

    BUFFER=" git add $(echo "$SELECTED_FILE" | tr '\n' ' ')"
    zle accept-line
}
zle -N __peco-git-add && bindkey "^ga" $_


## git checkout
function __peco-git-checkout()
{
    BUFFER=" git checkout $(git branch -a | peco | sed -e 's/^..//g' -e '/->/d' | awk '!a[$0]++')"
    zle accept-line
}
zle -N __peco-git-checkout && bindkey "^go" $_


## git graph
function __git-graph()
{
    BUFFER=" git log --graph --all --pretty=format:'%C(green)%cd%C(reset) %C(red)%h%C(reset) %C(yellow bold)%d%C(reset) %C(bold)%s%C(reset) %C(blue bold)<%an>%C(reset)' --abbrev-commit --date=format:'%Y-%m-%d %H:%M'"
    zle accept-line
}
zle -N __git-graph && bindkey "^gg" $_


## git graph rich
function __git-graph-rich()
{
    BUFFER=" git log --graph --all --pretty=format:'%C(red reverse)%d%Creset%C(white reverse) %h% Creset %C(green reverse) %an %Creset %C(cyan bold)%ad (%ar)%Creset%n%C(white bold)%w(80)%s%Creset%n%n%w(80,2,2)%b' --abbrev-commit --date=format:'%Y-%m-%d %H:%M:%S' --name-status"
    zle accept-line
}
zle -N __git-graph-rich && bindkey "^g^g" $_


## set command 'git commit'
function __git-commit()
{
    BUFFER="git commit -m ''"
    CURSOR=$(($#BUFFER - 1))
}
zle -N __git-commit && bindkey "^gc" $_


## utils
function __cd-git-root
{
    if [[ $(get-git-dir-depth) != '0' ]]; then
        builtin cd $(get-git-root-dir)
    fi
    zle reset-prompt
}
zle -N __cd-git-root && bindkey "^gr" $_

function get-path-from-git-root {
  git rev-parse --show-prefix 2> /dev/null
}

function get-git-root-dir
{
    if [[ $(get-git-dir-depth) != '0' ]]; then
        local REL_PATH_FROM_GIT_ROOT=$(get-path-from-git-root | perl -pe 's!/$!!')
        pwd | perl -pe "s!${REL_PATH_FROM_GIT_ROOT}/?\$!!"
    fi
}

function get-git-dir-depth
{
    local depth=$(get-path-from-git-root | head -n1 | perl -ne 'print s!/!!g')
    if [[ $depth == '' ]];then
        echo '0'
    else
        echo $depth
    fi
}

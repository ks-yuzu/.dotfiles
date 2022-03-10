## git status
function __git-status()
{
    # if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
        echo git status -sb
        git status -sb
        echo '\n'
    # fi
    zle reset-prompt
}
zle -N __git-status && bindkey "^gs" $_


## git diff
function __peco-git-diff()
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
zle -N __peco-git-diff && bindkey "^gd" $_


## git add
function __peco-git-add()
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
zle -N __peco-git-add && bindkey "^ga" $_


## git checkout
function __peco-git-checkout()
{
    git checkout $(git branch -a | peco | sed -e 's/^..//g' -e '/->/d' | awk '!a[$0]++')
    zle reset-prompt
}
zle -N __peco-git-checkout && bindkey "^go" $_


## git graph
function __git-graph()
{
    git log --graph --all --pretty=format:'%C(green)%cd%C(reset) %C(red)%h%C(reset) %C(yellow bold)%d%C(reset) %C(bold)%s%C(reset) %C(blue bold)<%an>%C(reset)' --abbrev-commit --date=format:'%Y-%m-%d %H:%M'
    zle reset-prompt
}
zle -N __git-graph && bindkey "^gg" $_


## git graph rich
function __git-graph-rich()
{
    git log --graph --all --pretty=format:'%C(red reverse)%d%Creset%C(white reverse) %h% Creset %C(green reverse) %an %Creset %C(cyan bold)%ad (%ar)%Creset%n%C(white bold)%w(80)%s%Creset%n%n%w(80,2,2)%b' --abbrev-commit --date=format:'%Y-%m-%d %H:%M:%S' --name-status
    zle reset-prompt
}
zle -N __git-graph-rich && bindkey "^g^g" $_


## git commit -v
function __git-commit()
{
    # git commit -v
    # zle reset-prompt
    BUFFER="git commit -m ''"
    CURSOR=15

}
zle -N __git-commit && bindkey "^gc" $_


function __cd-git-root
{
    if [[ $(get-git-dir-depth) != '0' ]]; then
        cd $(get-git-root-dir)
    fi
    zle reset-prompt
}
zle -N __cd-git-root && bindkey "^gr" $_


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

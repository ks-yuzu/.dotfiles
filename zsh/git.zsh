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

    pushd 2> /dev/null
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

    popd > /dev/null
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
    git checkout `git branch | peco | sed -e "s/\* //g" | awk "{print \$1}"`
    zle reset-prompt
}
zle -N peco-git-checkout
bindkey "^go" peco-git-checkout


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

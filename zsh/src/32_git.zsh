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
  #local GIT_ROOT="$(perl -e "print '../' x $(get-git-dir-depth)")"
  local GIT_ROOT="$(git rev-parse --show-toplevel)"

  local GIT_STATUS="$(git status --porcelain)"
  if [ -z "$GIT_STATUS" ]; then
    echo ''
    BUFFER=' git status'
  else
    local SELECTED_FILES="$( \
      echo "$GIT_STATUS" \
      | grep '^[ AMRD]M' \
      | peco --query "$LBUFFER" \
      | cut -b4- \
      | sed -e 's/^.* -> //' \
    )"
    [ -n "$SELECTED_FILES" ] || return

    FILE_PATHS="$(echo "$SELECTED_FILES" | xargs -I{} echo $GIT_ROOT/{} | xargs)"
    BUFFER=" git diff ${FILE_PATHS}"
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
  local SELECTED_FILES="$( \
    git status --short \
    | peco --query "$LBUFFER" \
    | cut -b4- \
    | sed -e 's/^.* -> //' \
    | tr '\n' ' ' \
  )"
  [ -n "$SELECTED_FILES" ] || return

  BUFFER=" git add $SELECTED_FILES"
  zle accept-line
}
zle -N __peco-git-add && bindkey "^ga" $_


## git checkout
function __peco-git-checkout()
{
  branch=$(git branch -a | peco | sed -e 's/^..//g' -e '/->/d' | awk '!a[$0]++')
  if [[ "$branch" =~ "remotes/origin/" ]]; then
    branch=$(echo $branch | sed -e 's|remotes/origin/||')
    BUFFER=" git checkout -b $branch origin/$branch"
  else
    BUFFER=" git switch $branch"
  fi
  CURSOR=$#BUFFER
}
zle -N __peco-git-checkout && bindkey "^go" $_

## git checkout
function __peco-git-fetch-and-switch()
{
  branch=$(git branch -a | peco | sed -e 's/^..//g' -e '/->/d' | awk '!a[$0]++')

  if [[ "$branch" =~ "remotes/origin/" ]]; then
    branch=$(echo $branch | sed -e 's|remotes/origin/||')
    BUFFER=" git fetch origin ${branch}:${branch} && git checkout -b $branch origin/$branch"
  else
    BUFFER=" git fetch origin ${branch}:${branch} && git switch ${branch}"
  fi
  CURSOR=$#BUFFER
}
zle -N __peco-git-fetch-and-switch && bindkey "^gO" $_

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


## fetch master
function __git-fetch-master()
{
    if [[ $(git branch | grep -c '^\s*master$') = 1 ]]; then
        local TARGET_BRANCH=master:master
    elif [[ $(git branch | grep -c '^\s*main$') = 1 ]]; then
        local TARGET_BRANCH=main:main
    fi
    BUFFER=" git fetch origin $TARGET_BRANCH"
    CURSOR=$#BUFFER
}
zle -N __git-fetch-master && bindkey "^gf" $_

function __git-checkout-pullrequest()
{
  BUFFER=" gh pr checkout"
  zle accept-line
}
zle -N __git-checkout-pullrequest && bindkey "^gp" $_

function __git-browse()
{
  BUFFER=" gh browse"
  zle accept-line
}
zle -N __git-browse && bindkey "^gb" $_


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
    git rev-parse --show-toplevel

#   if [[ $(get-git-dir-depth) != '0' ]]; then
#       local REL_PATH_FROM_GIT_ROOT=$(get-path-from-git-root | perl -pe 's!/$!!')
#       pwd | perl -pe "s!${REL_PATH_FROM_GIT_ROOT}/?\$!!"
#   fi
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


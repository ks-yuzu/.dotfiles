source ~/.dotfiles/zsh/plugins/fzf-git.zsh

## git status
function __git-status()
{
    BUFFER=' git status -sb'
    zle accept-line
}
zle -N __git-status && bindkey "^gs" $_

## git diff
function __git-diff-fzf() {
  local files=$(_fzf_git_files | xargs)
  if [[ -n "$files" ]]; then
    BUFFER=" git diff -- $files"
    zle accept-line
  fi
}
zle -N __git-diff-fzf && bindkey "^gd" $_

## git diff --cached
function __git-diff-cached() {
  BUFFER=' git diff --cached'
  zle accept-line
}
zle -N __git-diff-cached && bindkey "^gD" $_


function __git-add-fzf() {
  local files=$(_fzf_git_files | xargs)
  if [[ -n "$files" ]]; then
    BUFFER=" git add $files"
    zle accept-line
  fi
}
zle -N __git-add-fzf && bindkey "^ga" $_


## git checkout
function __git-switch-fzf()
{
  local branch=$(_fzf_git_branches)
  [[ -z "$branch" ]] && return

  if [[ "$branch" =~ "origin/" ]]; then
    local branch=$(echo $branch | sed -e 's|origin/||')
    BUFFER=" git switch -c $branch origin/$branch"
  else
    BUFFER=" git switch $branch"
  fi
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N __git-switch-fzf && bindkey "^go" $_

## git checkout
function __git-fetch-and-switch-fzf()
{
  local branch=$(_fzf_git_branches)
  [[ -z "$branch" ]] && return

  if [[ "$branch" =~ "origin/" ]]; then
    local branch=$(echo $branch | sed -e 's|origin/||')
    # BUFFER=" git fetch origin ${branch}:${branch} && git checkout -b $branch origin/$branch"
  #   BUFFER=" git fetch origin ${branch}:${branch} && git switch -c $branch origin/$branch"
  # else
  #   BUFFER=" git fetch origin ${branch}:${branch} && git switch ${branch}"
  fi
  BUFFER=" git fetch origin ${branch}:${branch} && git switch ${branch}"
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N __git-fetch-and-switch-fzf && bindkey "^gO" $_

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
  # BUFFER=" gh pr checkout"
  # zle accept-line
  pr=$(
    gh pr list | column -s $'\t' -t \
      | fzf --accept-nth=1 \
            --preview 'unbuffer gh pr view -c {1}; echo -e "\n\n---"; unbuffer gh pr diff {1}' \
            --bind "alt-a:reload(gh pr list -s all -L 1000 | column -s $'\t' -t)" \
            --bind 'alt-c:execute(gh pr checkout {1})+abort' \
            --bind 'alt-w:execute(gh pr view -w {1})+abort' \
  )
  [[ -z "$pr" ]] && return

  BUFFER=" gh pr view $pr"
  CURSOR=$#BUFFER
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


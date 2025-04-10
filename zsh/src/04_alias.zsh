###################
#      alias
###################
alias ls='ls -F --show-control-chars --color=auto'
alias la='ls -a'
alias ll='ls -l --si --time-style=long-iso'
alias ltr='ls -l -tr'
alias lal='ls -l --almost-all --si --time-style=long-iso'
alias laltr='ls -al -tr --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'

alias tmux='tmux -2'

alias e='emacsclient -n'
alias ekill="emacsclient -e '(kill-emacs)'"
#alias ed='emacs --daemon'

if which xdg-open >/dev/null 2>&1 ; then
  alias op='xdg-open'
  alias open='xdg-open'
fi

which colordiff >/dev/null 2>&1 && alias cdiff='colordiff -u'
which bat       >/dev/null 2>&1 && alias cat='bat --paging=never'
which fzf       >/dev/null 2>&1 && alias ff='fzf'

#alias conky='conky -b NL'
#alias guake='guake &'
alias octave='octave --no-gui'

alias gcc='gcc -Wall -Wextra -std=c11                               -Winline'
alias g++='g++ -Wall -Wextra -std=c++17 -Weffc++ -Wsuggest-override -Winline'

alias dropbox='dropbox.py $(dropbox.py help | grep -P "^ " | peco | awk "{print \$1}")'


# ===== suffix alias =====
alias -s txt='cat'
alias -s html='google-chrome-stable'
alias -s pdf='evince'

# ===== global alias =====
# alias -g G='| grep'
# alias -g L='| less'
alias -g NL='>/dev/null 2>&1 &'


function cd() { builtin cd $@ && ls --color; }
function pr-select { gh pr list| peco | awk '{print $1}' }

function ssh() {
  timestamp=$(date --iso-8601=seconds); echo $timestamp
  joined_args=$(perl -e '$args = join "_", (grep { $_ !~ /^\-/ } @ARGV); print ${args}' $@)
  logfile="$HOME/works/ssh-log/ssh-${timestamp}-${joined_args}.log"

  if script /dev/null -c : > /dev/null; then
      script $logfile -c "/usr/bin/ssh $@" # for linux
  else
      script $logfile /usr/bin/ssh $@      # for BSD
  fi
}

## clipboard
if ! (( ${+commands[pbpaste]} )); then
  (( ${+commands[win32yank.exe]} )) && alias pbpaste='win32yank.exe -o'
fi

if   which pbcopy        >/dev/null 2>&1; then alias -g clip='tee >(pbcopy)'                   # Linux
elif which xsel          >/dev/null 2>&1; then alias -g clip='tee >(xsel --input --clipboard)' # Mac
elif which putclip       >/dev/null 2>&1; then alias -g clip='tee >(putclip)'                  # Cygwin
elif which win32yank.exe >/dev/null 2>&1; then alias -g clip='tee >(win32yank.exe -i)'         # Windows
elif which clip.exe      >/dev/null 2>&1; then alias -g clip='tee >(clip.exe)'                 # Windows
fi

## container
(( ${+commands[docker]} )) && alias bake='IMAGE_TAG=$(git rev-parse --short HEAD) docker buildx bake'


function grd() {
  docker run --rm -it -p 8080:8080 -v ~/.config/grizzly:/root/.config/grizzly -v .:/workdir -w /workdir grafana/grizzly $@
}

function grdc() {
  local context=$(grd config get-contexts | tail -n +2 | peco --query "$1" --select-1 | cut -c3-)
  if [ -z "$context" ]; then
    return 1
  fi
  grd config use-context $context
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
  "pr"    " gh pr create -fw"
  "k"     "kubectl"
  "t"     "terraform"
  "tg"    "terragrunt"
  "awksum" "awk '{ for (i=1; i<=NF; i++) { sum+=$i } } END { print sum }'"
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

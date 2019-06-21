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


function cd() { builtin cd $@ && ls; }
alias cdt='cd ..'

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


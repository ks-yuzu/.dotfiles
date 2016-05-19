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

alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'

alias tmux='tmux -2'

alias conky='conky -b NL'
alias guake='guake &'

alias acap='acap.pl'
alias ise='ise NL'

alias e='emacsclient -n'
alias ekill="emacsclient -e '(kill-emacs)'"
alias ed='emacs --daemon'

alias gitst='git status'

alias op='xdg-open'
alias open='xdg-open'

# suffix alias
alias -s txt='cat'
alias -s html='google-chrome'
alias -s pdf='evince'

# global alias
# alias -g G='| grep'
# alias -g L='| less'
alias -g NL='>/dev/null 2>&1 &'

alias pm-suspend="echo \"[alias] 'pm-suspend' does not work well on Ubuntu14.04\""
alias sshdius="sshpass -p feketerigo ssh -l stu3522 dius02.ksc.kwansei.ac.jp"


alias sdedit="java -jar ~/bin/sdedit-4.2-beta7.jar $*"
alias plantuml="java -jar ~/bin/plantuml.jar $*"


function cd() { builtin cd $@ && ls; }


# copy stdin to clipboard
# ref : http://mollifier.hatenablog.com/entry/20100317/p1
#if which pbcopy >/dev/null 2>&1 ; then    # Mac
#    alias -g clip="echo 'test'"
#        alias -g clip='pbcopy'
    if [ which xsel >/dev/null 2>&1 ]; && alias -g clip='xsel --input --clipboard'
#    elif which putclip >/dev/null 2>&1 ; then # Cygwin
#        alias -g clip='putclip'	      
#fi




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

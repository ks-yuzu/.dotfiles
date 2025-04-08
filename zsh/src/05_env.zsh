export LC_TIME='C'
export TIMEFMT=$'\n\n========================\nCommand: %J\nCPU:     %P\nuser:    %*Us\nsystem:  %*Ss\ntotal:   %*Es\n========================\n'

export LYNX_CFG=~/.lynx
#export EDITOR='emacsclient -t'
export CVSEDITOR="${EDITOR}"
export SVN_EDITOR="${EDITOR}"
export GIT_EDITOR="${EDITOR}"

#export VISUAL='emacsclient -t'
export LESS='-N -M -R -s +Gg'
export BAT_PAGER="less -n"
FZF_DEFAULT_OPTS_ARRAY=(
  '--exact'
  '--no-sort'
  '--cycle'
  '--multi'
  '--no-mouse'
  '--tmux 98%,90%'
  '--reverse'
  '--prompt="query> "'
  '--color=16'
  '--bind="ctrl-v:page-down,alt-v:page-up,ctrl-d:delete-char,ctrl-j:accept,ctrl-k:kill-line,ctrl-space:toggle+down"'
  '--bind="tab:preview:[ -d {} ] && ls -l --almost-all --si --time-style=long-iso {} || bat --color=always {}"'
  '--bind="ctrl-t:change-preview-window:right|bottom"'
  '--marker="✅"'
  '--color=fg:#d0d0d0,fg+:#d0d0d0,bg:#121212,bg+:#005470'
  '--color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00'
  '--color=prompt:#0039d6,spinner:#af5fff,pointer:#0032d8,header:#87afaf'
  '--color=gutter:#121212,border:#262626'
  '--border="rounded" --border-label="" --preview-window="border-rounded"'
)
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS_ARRAY[*]}"
export FZF_DEFAULT_COMMAND='which rgi && rgi || ls'

export AWS_DEFAULT_REGION=ap-northeast-1
export KUBECTL_EXTERNAL_DIFF='colordiff -u'
export USE_GKE_GCLOUD_AUTH_PLUGIN=True



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

export FZF_DEFAULT_OPTS="--cycle --no-mouse --reverse --prompt='QUERY> ' --color=16"

export AWS_DEFAULT_REGION=ap-northeast-1
export KUBECTL_EXTERNAL_DIFF='colordiff -u'
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

autoload -Uz add-zsh-hook

## tmux info disp
function disp-tmux-info()
{
    [[ $TERM =~ 'screen' ]] || return

    local NUM_SESSIONS=$(tmux list-sessions | wc -l)
    local NUM_WINDOWS=$( tmux list-windows  | wc -l)

    local CURR_SESSION_ID=$(tmux display -p '#S')
    local CURR_WINDOW_ID=$( tmux display -p '#I')

    local CURR_SESSION_NUM=$(tmux ls  | grep -n "^$CURR_SESSION_ID" | perl -ne 'print /^(\d+)/')
    local CURR_WINDOW_NUM=$( tmux lsw | grep -n "^$CURR_WINDOW_ID"  | perl -ne 'print /^(\d+)/')

    echo -n "W $CURR_WINDOW_NUM/$NUM_WINDOWS (WID:$CURR_WINDOW_ID), S $CURR_SESSION_NUM/$NUM_SESSIONS (SID:$CURR_SESSION_ID)"
}

function disp-tmux-info-mini()
{
    [[ $TERM =~ 'screen' ]] || return

    local NUM_SESSIONS=$(tmux list-sessions | wc -l)
    local NUM_WINDOWS=$( tmux list-windows  | wc -l)

    local CURR_SESSION_ID=$(tmux display -p '#S')
    local CURR_WINDOW_ID=$( tmux display -p '#I')

    local CURR_SESSION_NUM=$(tmux ls  | grep -n "^$CURR_SESSION_ID" | perl -ne 'print /^(\d+)/')
    local CURR_WINDOW_NUM=$( tmux lsw | grep -n "^$CURR_WINDOW_ID"  | perl -ne 'print /^(\d+)/')

    echo -n "W:$CURR_WINDOW_NUM/$NUM_WINDOWS S:$CURR_SESSION_NUM/$NUM_SESSIONS"
}

function disp-tmux-info-for-prompt()
{
    [[ $TERM =~ 'screen' ]] || return
    echo -n "[" $(disp-tmux-info-mini) "] "
}

function get-kube-cluster-info() {
    which kubectl > /dev/null || return

    local kube_context=$(kubectl config current-context 2> /dev/null)
    [[ "$?" != "0" ]] || return

    if [[ "$_KUBE_CONTEXT" != "$kube_context" ]]; then
        _KUBE_CONTEXT=$kube_context
    else
        echo $_K8S_CLUSTER_INFO
        return
    fi

    if [[ $_KUBE_CONTEXT =~ gke ]]; then
        # _K8S_CLUSTER_INFO=" \e[38;5;33mgke:\e[m$(echo $_KUBE_CONTEXT | cut -d_ -f4-)"
        _K8S_CLUSTER_INFO=" \e[38;5;33mgke:\e[m$(echo $_KUBE_CONTEXT | cut -d_ -f2,4 --output-delimiter '/')"
        # _K8S_CLUSTER_INFO=" $(imgcat ~/.dotfiles/zsh/icons/gke-icon.png; echo -n -e "\033[2C")$(echo $_KUBE_CONTEXT | cut -d_ -f4-)"
    elif [[ $_KUBE_CONTEXT =~ aws ]]; then
        local product=$(get-aws-account-name-from-id $(echo $_KUBE_CONTEXT | cut -d: -f5))
        # sts token のアカウントとクラスタのアカウントが違っていれば色を変える
        if [[ ! -n "$STS_EXPIRATION_UNIXTIME" ]]; then
            :
        elif [[ "${STS_ALIAS_SHORT:-$AWS_PRODUCT}" = "$product" ]]; then
            product="%F{green}${product}%f"
        else
            product="%F{red}${product}%f"
        fi
        _K8S_CLUSTER_INFO=" \e[38;5;202meks:\e[m${product}/$(echo $_KUBE_CONTEXT | cut -d/ -f2)"
        # _K8S_CLUSTER_INFO=" $(imgcat ~/.dotfiles/zsh/icons/eks-icon.png; echo -n -e "\033[2C")${product}:$(echo $_KUBE_CONTEXT | cut -d/ -f2)"
    else
        _K8S_CLUSTER_INFO=''
    fi

    echo $_K8S_CLUSTER_INFO
}

function get-kube-ns-info() {
    which kubectl > /dev/null || return
    # local NS=$(kubectl config view | grep namespace: | awk '{print $2}')
    local NS=$(kubectl config view | sed -n "/cluster: $(kubectl config current-context 2> /dev/null | perl -pe 's|/|\\/|g')/,/^-/p" | grep namespace | awk '{print $2}')
    if [[ -z "$NS" ]]; then
        return
    fi

    echo "($NS)"
}

function get-argocd-info() {
    which argocd > /dev/null || return
    ARGOCD_CONTEXT=$(argocd context | grep '^*' | awk '{print $2}' | cut -d. -f1)
    echo "\e[38;5;202margocd:\e[m${ARGOCD_CONTEXT}"
}

function _is_gcloud_config_updated() {
    local active_config config_default configurations
    local active_config_now config_default_now configurations_now
    local active_config_mtime config_default_mtime configurations_mtime mtime_fmt

    # if one of these files is modified, assume gcloud configuration is updated
    active_config="$HOME/.config/gcloud/active_config"
    config_default="$HOME/.config/gcloud/configurations/config_default"
    configurations="$HOME/.config/gcloud/configurations"

    zstyle -s ':zsh-gcloud-prompt:' mtime_fmt mtime_fmt

    active_config_now="$(stat $mtime_fmt $active_config 2>/dev/null)"
    config_default_now="$(stat $mtime_fmt $config_default 2>/dev/null)"
    configurations_now="$(stat $mtime_fmt $configurations 2>/dev/null)"

    zstyle -s ':zsh-gcloud-prompt:' active_config_mtime active_config_mtime
    zstyle -s ':zsh-gcloud-prompt:' config_default_mtime config_default_mtime
    zstyle -s ':zsh-gcloud-prompt:' configurations_mtime configurations_mtime

    if [[ "$active_config_mtime" != "$active_config_now" || "$config_default_mtime" != "$config_default_now" || "$configurations_mtime" != "$configurations_now" ]]; then
        zstyle ':zsh-gcloud-prompt:' active_config_mtime "$active_config_now"
        zstyle ':zsh-gcloud-prompt:' config_default_mtime "$config_default_now"
        zstyle ':zsh-gcloud-prompt:' configurations_mtime "$configurations_now"
        return 0
    else
        return 1
    fi
}

function _update_gcloud_context() {
    if _is_gcloud_config_updated; then
        # _GCLOUD_ACCOUNT="$(gcloud config get-value account 2>/dev/null)"
        _GCLOUD_PROJECT="$(gcloud config get-value project 2>/dev/null)"
    fi

    return 0
}


## prompt
function update-prompt()
{
    _update_gcloud_context

    if [ -n "$SSH_CONNECTION" ]; then
        host='%m'
    elif [ -f /.dockerenv ]; then
        host='docker'
    else
        host='local'
    fi

    local name="%F{green}%n@${host}%f"
    # local tmuxinfo=" %F{magenta}$(disp-tmux-info-for-prompt)%f"
    local tmuxinfo=""

    local kubeinfo="$(get-kube-cluster-info)$(get-kube-ns-info) "
    local argocdinfo="$(get-argocd-info) "
    local cdir="%F{yellow}%~%f "
    local endl=$'\n'
    local mark="%B%(?,%F{green},%F{red})%(!,#,>)%f%b "

    if ! is-wsl; then
      local kubeinfo="$(get-kube-cluster-info)$(get-kube-ns-info) "
      local face=''
      local info=''
      if [ -n "$AWS_PROFILE" ]; then
        info="$AWS_PROFILE"
      elif [ -z $STS_EXPIRATION_UNIXTIME ]; then
          face='(-ω-)zzz'
          info='(none)'
      else
          local lefttime="$(($STS_EXPIRATION_UNIXTIME - $(date +%s)))"

          if [ $lefttime -gt 0 ]; then
              face="('ω')"
              info="${STS_ALIAS_SHORT:-$AWS_PRODUCT}($lefttime)"
          else
              face='(>_<)'
              info="${STS_ALIAS_SHORT:-$AWS_PRODUCT}(%F{red}expired%f)"
          fi
      fi

      # local sts=" aws:${face}${info}"
      local sts=$' \e[38;5;202maws:\e[m'${info}
      # local sts=" $(imgcat ~/.dotfiles/zsh/icons/aws-icon.png; echo -n -e "\033[2C")${info}"
      local gcloud=$' \e[38;5;33mgcp:\e[m'${_GCLOUD_PROJECT:-(none)}
      # local gcloud=" $(imgcat ~/.dotfiles/zsh/icons/gcp-icon.png; echo -n -e "\033[2C")$_GCLOUD_PROJECT"
    fi

    if is-linux; then
        os_version="[$(cat /etc/os-release | grep VERSION_CODENAME | cut -d= -f2)]"
    fi

    PROMPT="${name}${tmuxinfo}${sts}${gcloud}${kubeinfo}${os_version}${argocdinfo}${cdir}${endl}${mark}"
}
# add-zsh-hook precmd update-prompt




# rev prompt
autoload -Uz vcs_info
autoload -Uz colors
colors

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' max-exports 6 # max number of variables in format
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}S"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}U"
zstyle ':vcs_info:git:*' formats '%b' '%r' '%c' '%u'
zstyle ':vcs_info:git:*' actionformats '%b@%r|%a' '%c' '%u'

setopt prompt_subst

function rprompt
{
    local repo=$(vcs_echo)
    [ -z "$repo" ] && return

    local dir=$(get-path-from-git-root)

    # local current_branch=$(git branch | grep '^*' | cut -d' ' -f2 | grep -v '(HEAD')
    # local upstream=$(git branch -vv | grep "^..$current_branch" | cut -d'[' -f2 | cut -d']' -f1)
    # if [ ! is-wsl ]; then
        local ahead_count=$(git rev-list --count HEAD...@'{u}' 2>/dev/null | xargs printf " %+d")
    # fi

    echo "[$repo /${dir}${ahead_count}]"
}

function vcs_echo
{
    STY= LANG=en_US.UTF-8 vcs_info

    local branch="$vcs_info_msg_0_"
    [ -z "$branch" ] && return

    local repo="$vcs_info_msg_1_"

    if   [[ -n "$vcs_info_msg_2_" ]];                then local color=${fg[yellow]} # staged
    elif [[ -n "$vcs_info_msg_3_" ]];                then local color=${fg[red]}    # unstaged
    elif [[ -n $(echo "$st" | grep "^Untracked") ]]; then local color=${fg[cyan]}   # untracked
    else                                                  local color=${fg[green]}
    fi

    echo "%{$color%}$branch%{$reset_color%}@%{$color%}$repo%{$reset_color%} ${vcs_info_msg_2_}${vcs_info_msg_3_}%{$reset_color%}"
}

function get-path-from-git-root
{
	git rev-parse --show-prefix 2> /dev/null
}

RPROMPT='$(rprompt)'


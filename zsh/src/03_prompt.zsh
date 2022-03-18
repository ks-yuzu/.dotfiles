autoload -Uz add-zsh-hook

## tmux
function get-tmux-info()
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

function get-tmux-info-mini()
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

function get-tmux-info-for-prompt()
{
    [[ $TERM =~ 'screen' ]] || return
    echo -n "[" $(get-tmux-info-mini) "] "
}


# k8s
function get-kube-cluster-info() {
    which kubectl > /dev/null || return

  # local kube_context=$(kubectl config current-context 2> /dev/null)
    local kube_context=$(grep current-context ~/.kube/config | cut -d' ' -f2)
    [[ "$?" = "0" ]] || return

    if [[ "$_KUBE_CONTEXT" != "$kube_context" ]]; then
        _KUBE_CONTEXT=$kube_context
    else
        echo $_K8S_CLUSTER_INFO
        return
    fi

    if [[ $_KUBE_CONTEXT =~ gke ]]; then
        _K8S_CLUSTER_INFO=" \e[38;5;33mgke:\e[m$(echo $_KUBE_CONTEXT | cut -d_ -f2,4 --output-delimiter '/')"
      # _K8S_CLUSTER_INFO=" $(imgcat ~/.dotfiles/zsh/icons/gke-icon.png; echo -n -e "\033[2C")$(echo $_KUBE_CONTEXT | cut -d_ -f4-)"
    elif [[ $_KUBE_CONTEXT =~ aws ]]; then
        local product=$(get-aws-account-name-from-id $(echo $_KUBE_CONTEXT | cut -d: -f5))
        # sts token のアカウントとクラスタのアカウントが違っていれば色を変える
        if [[ -z "$STS_EXPIRATION_UNIXTIME" ]]; then
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

    local NS=$(kubectl config view\
                   | sed -n "/cluster: $(kubectl config current-context 2> /dev/null | perl -pe 's|/|\\/|g')/,/^-/p"\
                   | grep namespace\
                   | awk '{print $2}')

    [[ -n "$NS" ]] || return
    echo "($NS)"
}

function get-argocd-info() {
    which argocd > /dev/null || return
    [ -f ~/.argocd/config ] || return
  # local ARGOCD_CONTEXT=$(argocd context | grep '^*' | awk '{print $2}' | cut -d. -f1 | sed -E 's/-?argo-?cd//')
    local ARGOCD_CONTEXT=$(grep '^current-context' ~/.argocd/config | cut -d' ' -f2 | cut -d. -f1 | sed -E 's/-?argo-?cd//')

    echo " \e[38;5;202margocd:\e[m${ARGOCD_CONTEXT}"
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

    local cdir=" %F{yellow}%~%f"
    local endl=$'\n'
    local mark="%B%(?,%F{green},%F{red})%(!,#,>)%f%b "

    if [ -n "$SHOW_KUBEINFO_IN_PROMPT" ]; then
      # local kubeinfo="$(get-kube-cluster-info)$(get-kube-ns-info)"
        local kubeinfo="$(get-kube-cluster-info)"
    fi

    local argocdinfo="$(get-argocd-info)"

    if [ -n "$SHOW_STSINFO_IN_PROMPT" ]; then
      local stsface=''
      local ststext=''
      if [ -n "$AWS_PROFILE" ]; then
        ststext="$AWS_PROFILE"
      elif [ -z $STS_EXPIRATION_UNIXTIME ]; then
        #stsface='(-ω-)zzz'
        ststext='(none)'
      else
        local lefttime="$(($STS_EXPIRATION_UNIXTIME - $(date +%s)))"

        if [ $lefttime -gt 0 ]; then
          #stsface="('ω')"
          ststext="${STS_ALIAS_SHORT:-$AWS_PRODUCT}($lefttime)"
        else
          #stsface='(>_<)'
          ststext="${STS_ALIAS_SHORT:-$AWS_PRODUCT}(%F{red}expired%f)"
        fi
      fi

      local stsinfo=$' \e[38;5;202maws:\e[m'${ststext}
      # local sts=" $(imgcat ~/.dotfiles/zsh/icons/aws-icon.png; echo -n -e "\033[2C")${info}"
    fi

    if [ -n "$SHOW_GCLOUDINFO_IN_PROMPT" ]; then
      local gcloudinfo=$' \e[38;5;33mgcp:\e[m'${_GCLOUD_PROJECT:-(none)}
      # local gcloud=" $(imgcat ~/.dotfiles/zsh/icons/gcp-icon.png; echo -n -e "\033[2C")$_GCLOUD_PROJECT"
    fi

    if is-linux; then
        os_version="[$(cat /etc/os-release | grep VERSION_CODENAME | cut -d= -f2)]"
    fi

    PROMPT="${name}${os_version}${tmuxinfo}${stsinfo}${gcloudinfo}${kubeinfo}${argocdinfo}${cdir}${endl}${mark}"
}
# add-zsh-hook precmd update-prompt




# reverse prompt
autoload -Uz vcs_info
autoload -Uz colors
colors

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' max-exports 6 # max number of variables in format
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '%b' '%r' '%c' '%u'
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}S"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}U"
zstyle ':vcs_info:git:*' actionformats '%b@%r|%a' '%c' '%u'

setopt prompt_subst

function rprompt
{
    STY= LANG=en_US.UTF-8 vcs_info

    local branch="$vcs_info_msg_0_"
    [ -n "$branch" ] || return

    if   [[ -n "$vcs_info_msg_2_" ]];       then local color=${fg[yellow]} # staged
    elif [[ -n "$vcs_info_msg_3_" ]];       then local color=${fg[red]}    # unstaged
    elif git status | grep -q '^Untracked'; then local color=${fg[cyan]}   # untracked
    else                                         local color=${fg[green]}
    fi

    # local repo="$vcs_info_msg_1_"
    local commit_date=$(git log --date=format:"%Y%m%d" --pretty=format:"%ad" -1)
    # local path_from_repo_root=$(git rev-parse --show-prefix 2> /dev/null)
    local ahead_count=$(git rev-list --count HEAD...@'{u}' 2>/dev/null | xargs printf " %+d")

    # local repo_status="%{$color%}${branch}%{$reset_color%}@%{$color%}${repo}%{$reset_color%} ${vcs_info_msg_2_}${vcs_info_msg_3_}%{$reset_color%}"
    # echo "[${repo_status} /${dir}${ahead_count}]"

    local branch_status="%{$color%}${branch}%F{#ccc}@${commit_date}%{$reset_color%}"
    echo "[${branch_status} ${vcs_info_msg_2_}${vcs_info_msg_3_}%{$reset_color%} ${ahead_count}]"
}

RPROMPT='$(rprompt)'


function __kubectx-fzf {
  local ctx=$(
    #| xargs -I{} bash -c 'cut -d: -f5 <<<{} | xargs get-aws-account-name-from-id 2>/dev/null | tr "\n" " "; echo {}' | column -t \
    kubectx \
      | fzf --preview 'kubectl config view --minify --context={}' \
  )
  [ -z "$ctx" ] && return

  # BUFFER=" kubectx $ctx"
  # echo $BUFFER
  # [ -n "$WIDGET" ] && zle accept-line
  command=" kubectx $ctx"
  echo $command && eval $command

  if [[ "$ctx" =~ ^arn:aws:eks: ]]; then
      if [[ "$(kubectx -c)" = "$ctx" ]]; then
        which get-aws-credential-for-eks-context > /dev/null && get-aws-credential-for-eks-context
      fi
  fi

  BUFFER=""
  zle accept-line
}
zle -N __kubectx-fzf && bindkey '^k^k' $_
# bindkey '^[k'  $_
# bindkey '^[^k' $_

function __k9s {
  # workaround: column select key bindings
  # https://github.com/derailed/k9s/issues/3768#issuecomment-4660516023
  TERM=xterm-256color k9s
}
zle -N __k9s && bindkey '^[9' $_

function __k9s-fzf {
  #               $(kubectx -c)
  # : ${PECO_QUERY:=$(grep -Po '(?<=current-context: ).*' ~/.kube/config)}
  local ctx=$(
    kubectx \
      | fzf --query "$PECO_QUERY" \
            --preview 'kubectl config view --minify --context={}'
  )
  [ -z "$ctx" ] && return

  BUFFER=" KUBECONFIG='$KUBECONFIG' TERM=xterm-256color k9s --context $ctx"
  [ -n "$WIDGET" ] && zle accept-line
}
zle -N __k9s-fzf && bindkey '^[(' $_

function __k9s-with-default-kubeconfig-fzf {
  KUBECONFIG= PECO_QUERY=' ' __k9s-fzf
  [ -n "$WIDGET" ] && zle accept-line
}
zle -N __k9s-with-default-kubeconfig-fzf && bindkey '^u^[9' $_ && bindkey '^k^9' $_

KUSTOMIZA_SNAPSHOT_FILE=.kustomize-snapshot.yaml
HELMFILE_SNAPSHOT_FILE=.helmfile-snapshot.yaml

function __k8s-manifest-build()
{
  if [[ -f kustomization.yaml ]]; then
    BUFFER=" kustomize build --enable-alpha-plugins --enable-exec --enable-helm --load-restrictor LoadRestrictionsNone . 2>&1 | less"
  elif [[ -f helmfile.yaml || -f helmfile.yml ]]; then
    BUFFER=" helmfile template | less"
  fi
  zle accept-line
}
zle -N __k8s-manifest-build && bindkey "^[^b" $_

function __k8s-manifest-build-and-diff()
{
  if [[ -f kustomization.yaml ]]; then
    BUFFER=" (colordiff -u ${KUSTOMIZA_SNAPSHOT_FILE} <(kustomize build --enable-alpha-plugins --enable-exec --enable-helm --load-restrictor LoadRestrictionsNone .)) 2>&1 | less"
  elif [[ -f helmfile.yaml || -f helmfile.yml ]]; then
    BUFFER=" colordiff -u ${HELMFILE_SNAPSHOT_FILE} <(helmfile template) | less"
  fi
  zle accept-line
}
zle -N __k8s-manifest-build-and-diff && bindkey "^u^[^b" $_

function __k8s-manifest-build-and-tee()
{
  if [[ -f kustomization.yaml ]]; then
    BUFFER=" (kustomize build --enable-alpha-plugins --enable-exec --enable-helm --load-restrictor LoadRestrictionsNone . | tee ${KUSTOMIZA_SNAPSHOT_FILE}) 2>&1 | less"
  elif [[ -f helmfile.yaml || -f helmfile.yml ]]; then
    BUFFER=" helmfile template | tee ${HELMFILE_SNAPSHOT_FILE} | less"
  fi
  zle accept-line
}
zle -N __k8s-manifest-build-and-tee && bindkey "^u^u^[^b" $_

function __k8s-manifest-diff()
{
  if [[ -f kustomization.yaml ]]; then
    BUFFER=" (kustomize build --enable-alpha-plugins --enable-exec --enable-helm --load-restrictor LoadRestrictionsNone . | kubectl diff ${KUBECTL_DIFF_OPTIONS} -f -) 2>&1 | less"
  elif [[ -f helmfile.yaml || -f helmfile.yml ]]; then
    BUFFER=" helmfile template | kubectl diff ${KUBECTL_DIFF_OPTIONS} -f - | less"
  fi
  zle accept-line
}
zle -N __k8s-manifest-diff && bindkey "^[^d" $_ && bindkey "^kd" $_

function __k8s-manifest-dyff()
{
  if [[ -f kustomization.yaml ]]; then
    BUFFER=" (kustomize build --enable-alpha-plugins --enable-exec --enable-helm --load-restrictor LoadRestrictionsNone . | KUBECTL_EXTERNAL_DIFF='dyff -c on between -bi --set-exit-code' kubectl diff ${KUBECTL_DIFF_OPTIONS} -f -) 2>&1 | less"
  elif [[ -f helmfile.yaml || -f helmfile.yml ]]; then
    BUFFER=" helmfile template | KUBECTL_EXTERNAL_DIFF='dyff -c on between -bi --set-exit-code' kubectl diff -f - | less"
  fi
  zle accept-line
}
zle -N __k8s-manifest-dyff && bindkey "^u^[^d" $_


# function __k8s-manifest-apply-selectively()
# {
#   if [[ -f kustomization.yaml ]]; then
#     COMMANDS=(
#       'echo'
#       ';'
#       'MANIFEST="$(kustomize build --enable-alpha-plugins --enable-exec --enable-helm --load-restrictor LoadRestrictionsNone . | fzf-yaml-filter)"'
#       ';'
#       'DIFF="$(echo "$MANIFEST" | kubectl diff ${KUBECTL_DIFF_OPTIONS} -f -)"'
#       ';'
#       '[ -n "$DIFF" ] || {echo "no changes detected"; return}'
#       ';'
#       'echo "$DIFF" | less -F'
#       '&&'
#       'read -q "?Enter \"y\" to apply the above changes: "'
#       '&&'
#       'echo'
#       '&&'
#       'echo "$MANIFEST" | kubectl apply ${KUBECTL_DIFF_OPTIONS} -f -'
#     )
#     BUFFER=" ${COMMANDS[*]}"
#   elif [[ -f helmfile.yaml || -f helmfile.yml ]]; then
#     BUFFER=" helmfile template | fzf-yaml-filter | kubectl diff ${KUBECTL_DIFF_OPTIONS} -f - | less"
#   else
#     echo "Error: No kustomization.yaml or helmfile.yaml found" >&2
#     return 1
#   fi
#   zle accept-line
# }
function __k8s-manifest-apply-selectively() {
  emulate -L zsh
  setopt pipefail

  local manifest diff status answer opts_str diff_status
  local -a kubectl_diff_options

  opts_str=${KUBECTL_DIFF_OPTIONS-}
  kubectl_diff_options=("${(@Q)${(z)opts_str}}")

  manifest=$(mktemp "${TMPDIR:-/tmp}/k8s-manifest.XXXXXX") || return
  diff=$(mktemp "${TMPDIR:-/tmp}/k8s-diff.XXXXXX") || {
    rm -f -- "$manifest"
    return 1
  }

  echo building manifest...

  {
    kustomize build \
      --enable-alpha-plugins \
      --enable-exec \
      --enable-helm \
      --load-restrictor LoadRestrictionsNone \
      . \
      | fzf-yaml-filter > "$manifest" || return

    kubectl diff "${kubectl_diff_options[@]}" -f "$manifest" > "$diff"
    diff_status=$status

    case "$diff_status" in
      0)
        echo "no changes detected"
        ;;
      1)
        less -RF -- "$diff" || return
        read -q 'answer?Apply the above changes? [y/N]: '
        echo
        if [[ "$answer" == y ]]; then
          kubectl apply "${kubectl_diff_options[@]}" -f "$manifest"
        fi
        ;;
      *)
        echo "kubectl diff failed with status $diff_status" >&2
        return "$diff_status"
        ;;
    esac
  } always {
    rm -f -- "$manifest" "$diff"
  }

  echo "\n"
  zle reset-prompt
}
zle -N __k8s-manifest-apply-selectively && bindkey "^kA" $_

# kustomize の overlay を選択して移動
# - preview: ディレクトリ内のファイル一覧, kustomization.yaml の中身
# - bind:
#   - tab: 選択中のディレクトリで kustomize build
function __k8s-switch-kustomize-overlay()
{
  if ! (pwd | grep -P '/overlays?') > /dev/null; then
    echo "Error: Not in overlays directory" >&2
    return 1
  fi

  OVERLAYS_DIR=$(pwd | grep -Po '.*/overlays?')
  dir=$(
    # builtin cd $OVERLAYS_DIR;
    find $OVERLAYS_DIR -name kustomization.yaml \
      | xargs dirname \
      | sed -e "s|$OVERLAYS_DIR/||" \
      | fzf --preview "bat --color=always ${OVERLAYS_DIR}/{}/kustomization.yaml; ls -l --almost-all --si --time-style=long-iso ${OVERLAYS_DIR}/{}" \
            --bind "tab:preview:kustomize build --enable-alpha-plugins --enable-exec --enable-helm --load-restrictor LoadRestrictionsNone ${OVERLAYS_DIR}/{} 2>&1" \
      | xargs -I{} echo "${OVERLAYS_DIR}/{}"
  )
  if [ -z "$dir" ]; then
    return 1
  fi

  [ $#BUFFER -gt 0 ] && zle push-line-or-edit
  BUFFER=" builtin cd '$dir'"
  zle accept-line
}
# zle -N __k8s-switch-kustomize-overlay && bindkey "^[o" $_

# kustomize のディレクトリを選択して移動
# - preview: ディレクトリ内のファイル一覧, kustomization.yaml の中身
# - bind:
#   - tab: 選択中のディレクトリで kustomize build
function __k8s-switch-kustomize-dir()
{
  if (pwd | grep -P '/(base|overlay|component)s?') > /dev/null; then
    KUSTOMIZE_ROOT_DIR=$(pwd | grep -Po '.*/(base|overlay|component)s?' | xargs dirname)
  elif =ls base* overlays > /dev/null; then
    KUSTOMIZE_ROOT_DIR=.
  else
    echo "Error: Not in kustomize directory" >&2
    return 1
  fi

  dir=$(
    find $KUSTOMIZE_ROOT_DIR -name kustomization.yaml \
      | xargs dirname \
      | sed -e "s|$KUSTOMIZE_ROOT_DIR||" \
      | fzf --preview "bat --color=always ${KUSTOMIZE_ROOT_DIR}/{}/kustomization.yaml; ls -l --almost-all --si --time-style=long-iso ${KUSTOMIZE_ROOT_DIR}/{}" \
            --bind "tab:preview:kustomize build --enable-alpha-plugins --enable-exec --enable-helm --load-restrictor LoadRestrictionsNone ${KUSTOMIZE_ROOT_DIR}/{} 2>&1" \
      | xargs -I{} echo "${KUSTOMIZE_ROOT_DIR}{}"
  )
  if [ -z "$dir" ]; then
    return 1
  fi

  [ $#BUFFER -gt 0 ] && zle push-line-or-edit
  BUFFER=" builtin cd '$dir'"
  zle accept-line
}
zle -N __k8s-switch-kustomize-dir && bindkey "^[o" $_
zle -N __k8s-switch-kustomize-dir && bindkey "^[^o" $_

# 選択したリソースの未 apply 差分を表示
# (個別に確認したい場合や、イミュータブルなフィールドを変更する時用)
# - preview: kustomize build の結果と actual state の差分
function kustomize-diff-fzf() {
  generated=/tmp/kustomize-diff-fzf.generated.yaml
  kustomize build --enable-alpha-plugins --enable-exec --enable-helm --load-restrictor LoadRestrictionsNone . > $generated

  local ignore_fields_list=(
    .status
    .metadata.uid
    .metadata.creationTimestamp
    .metadata.generation
    .metadata.resourceVersion
    .metadata.selfLink
    .metadata.annotations\[\"kubectl.kubernetes.io/last-applied-configuration\"\]
    .metadata.annotations\[\"deployment.kubernetes.io/revision\"\]
  )
  local ignore_fields=$(IFS=, ; echo "${ignore_fields_list[*]}")
  local preview_command=(
    "colordiff -u"
    "<(kubectl get {2} {3} -n {1} -o yaml | yq 'del(${ignore_fields})')"
    "<(cat $generated | yq 'select(.metadata.namespace == \"{1}\" and .kind == \"{2}\" and .metadata.name == \"{3}\")')"
  )

  resources=$(cat "$generated" | yq '"\(.metadata.namespace) \(.kind) \(.metadata.name)"' | column -t)
  echo "$resources" \
    | fzf --ansi \
          --preview "${preview_command[*]}" \
}

function kear() {
  if [ $# -gt 0 ]; then
    targets="$@"
    kustomize edit add resource $targets
  else
    # targets=$(=ls *.yaml | grep -v '^kustomization\.yaml$' | peco | xargs)
    targets=$(find . -mindepth 1 -maxdepth 1 '(' -type d -o -name '*.yaml' ')' -ls \
                | grep -vF -e ./kustomization.yaml -e ./.kustomize-snapshot.yaml \
                | sort -k 3,3 -k 11,11 \
                | peco \
                | awk '{print $11}' \
                | xargs )

    BUFFER=" kustomize edit add resource $targets"
    CURSOR=$#BUFFER
  fi

}
zle -N kear && bindkey "^[^r" $_

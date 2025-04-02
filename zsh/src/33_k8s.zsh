function __peco-kubectx {
  local ctx=$(kubectx | peco)
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
zle -N __peco-kubectx
bindkey '^[k'  $_
bindkey '^[^k' $_

function __peco-k9s {
  #               $(kubectx -c)
  : ${PECO_QUERY:=$(grep -Po '(?<=current-context: ).*' ~/.kube/config)}
  local ctx=$(kubectx | peco --query "$PECO_QUERY")
  [ -z "$ctx" ] && return

  BUFFER=" KUBECONFIG='$KUBECONFIG' k9s --context $ctx"
  [ -n "$WIDGET" ] && zle accept-line
}
zle -N __peco-k9s
bindkey '^[9' $_
bindkey '^[^t' $_

function __peco-k9s-with-default-kubeconfig {
  KUBECONFIG= PECO_QUERY=' ' __peco-k9s
  [ -n "$WIDGET" ] && zle accept-line
}
zle -N __peco-k9s-with-default-kubeconfig
bindkey '^u^[9' $_

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
    BUFFER=" helmfile diff | less"
  fi
  zle accept-line
}
zle -N __k8s-manifest-diff && bindkey "^[^d" $_

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
zle -N __k8s-switch-kustomize-overlay && bindkey "^[o" $_

# kustomize のディレクトリを選択して移動
# - preview: ディレクトリ内のファイル一覧, kustomization.yaml の中身
# - bind:
#   - tab: 選択中のディレクトリで kustomize build
function __k8s-switch-kustomize-dir()
{
  if ! (pwd | grep -P '/(base|overlay|component)s?') > /dev/null; then
    echo "Error: Not in kustomize directory" >&2
    return 1
  fi

  KUSTOMIZE_ROOT_DIR=$(pwd | grep -Po '.*/(base|overlay|component)s?' | xargs dirname)
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
zle -N __k8s-switch-kustomize-dir && bindkey "^[^o" $_

# 選択したリソースの未 apply 差分を表示
# (個別に確認したい場合や、イミュータブルなフィールドを変更する時用)
# - preview: kustomize build の結果と actual state の差分
function kustomize-diff-fzf() {
  generated=/tmp/kustomize-diff-fzf.generated.yaml
  kustomize build . > $generated

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

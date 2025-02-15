## period
function show-time()
{
  echo ""
  LC_TIME=c date --iso-8601=seconds | sed -e 's/T/ /g' -e 's/+09:00/ (JST)/'
}
PERIOD=30
add-zsh-hook periodic show-time


function _precmd() {
  (which auto-sts > /dev/null) && auto-sts

  RPROMPT='$(rprompt)'
  update-prompt
}
add-zsh-hook precmd _precmd


function _preexec() {
  if [[ "$1" =~ "^ *argocd app" ]]; then
    find ~/.argocd/config -mmin -$((12 * 60)) | grep -q .\
      || argocd login $(argocd context | sed -n '2,$p' | cut -c 4- | peco | awk '{print $1}') --grpc-web --sso
  fi
}

function on-accept-line() {
  RPROMPT='[%D{%Y/%m/%d %H:%M:%S}]'
  zle .reset-prompt
  zle .accept-line
}
zle -N accept-line on-accept-line

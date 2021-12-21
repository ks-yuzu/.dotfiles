## period
function show-time()
{
  echo ""
  LC_TIME=c date --iso-8601=minutes | sed -e 's/T/ /g' -e 's/^(.*)$/($1)/'
}
PERIOD=30
add-zsh-hook periodic show-time


function _precmd() {
  (which auto-sts > /dev/null) && auto-sts
  update-prompt
}
add-zsh-hook precmd _precmd


function _preexec() {
  if [[ "$1" =~ "^ *argocd app" ]]; then
    find ~/.argocd/config -mmin -$((12 * 60)) | grep -q .\
      || argocd login $(argocd context | sed -n '2,$p' | cut -c 4- | peco | awk '{print $1}') --grpc-web --sso
  fi
}

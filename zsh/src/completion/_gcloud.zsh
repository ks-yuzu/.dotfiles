function source-if-exists {
  file=$1
  if [ -f "$file" ]; then
    source "$file"
  else
    echo "$file is not found. skip."
  fi
}

source-if-exists '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'

# update PATH for the Google Cloud SDK.
source-if-exists "$HOME/google-cloud-sdk/path.zsh.inc"
# enable shell command completion for gcloud.
source-if-exists "$HOME/google-cloud-sdk/completion.zsh.inc"


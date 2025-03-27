function source-if-exists {
  file=$1
  if [ -f "$file" ]; then
    source "$file"
  else
    echo "$file is not found. skip."
  fi
}

GOOGLE_CLOUD_SDK=/usr/local/Caskroom/google-cloud-sdk/latest
source-if-exists "$GOOGLE_CLOUD_SDK/path.zsh.inc"
source-if-exists "$GOOGLE_CLOUD_SDK/completion.zsh.inc"

GOOGLE_CLOUD_SDK=/usr/share/google-cloud-sdk
source-if-exists "$GOOGLE_CLOUD_SDK/path.zsh.inc"
source-if-exists "$GOOGLE_CLOUD_SDK/completion.zsh.inc"


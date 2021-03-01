## period
function show-time()
{
    echo ""
    LC_TIME=c date --iso-8601=minutes | sed -e 's/T/ /g' -e 's/^(.*)$/($1)/'
}
PERIOD=30
add-zsh-hook periodic show-time


function auto-sts() {
    if [[ -z "$AWS_PRODUCT" ]]; then
         unset AWS_SECURITY_TOKEN
    else
      if [[ -z "$STS_EXPIRATION_UNIXTIME" ]]; then
          echo "\ngetting sts token...\n"
          export _STS_CURRENT_AWS_PRODUCT=$AWS_PRODUCT
          eval `stsenv`
      elif [[ "$_STS_CURRENT_AWS_PRODUCT" != "$AWS_PRODUCT" ]]; then
          echo "\nupdating sts token for account switching...\n"
          export _STS_CURRENT_AWS_PRODUCT=$AWS_PRODUCT
          eval `stsenv`
      elif [[ "$STS_EXPIRATION_UNIXTIME" -lt `date +%s` ]]; then
          echo "\nupdating sts token...\n"
          # export _STS_CURRENT_AWS_PRODUCT=$AWS_PRODUCT
          eval `stsenv`
      fi
    fi
}


function _precmd() {
    auto-sts
    update-prompt
}
add-zsh-hook precmd _precmd




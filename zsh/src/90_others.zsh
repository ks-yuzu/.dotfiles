## period
function show-time()
{
    echo ""
    LC_TIME=c date --iso-8601=minutes | sed -e 's/T/ /g' -e 's/^(.*)$/($1)/'
}
PERIOD=30
add-zsh-hook periodic show-time


function _precmd() {
    auto-sts
    update-prompt
}
add-zsh-hook precmd _precmd




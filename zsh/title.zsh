autoload -Uz add-zsh-hook

function rename_tmux_window() {
   if [ $TERM = "screen" ]; then
       local current_path=`pwd | sed -e s/\ /_/g`
       local current_dir=`basename $current_path`
       tmux rename-window $current_dir
   fi
}

add-zsh-hook precmd rename_tmux_window



#autoload -Uz vcs_info
#zstyle ':vcs_info:*' enable git svn
#zstyle ':vcs_info:*' formats '%r'
#
#precmd () {
#  LANG=en_US.UTF-8 vcs_info
#  [[ -n ${vcs_info_msg_0_} ]] && tmux rename-window $vcs_info_msg_0_
#}

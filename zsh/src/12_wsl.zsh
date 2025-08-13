# WSL 上のみ実行
if [[ `uname -a` =~ "Linux.*microsoft" ]]; then
  if [ -n "$INSIDE_EMACS" ]; then
    TERM=eterm-color
  fi

  umask 022
  export DISPLAY=localhost:0.0

  # (
  #   command_path="/mnt/c/Program Files/VcXsrv/vcxsrv.exe"
  #   command_name=$(basename "$command_path")

  #   if ! tasklist.exe 2> /dev/null | fgrep -q "$command_name"; then
  #     # "$command_path" :0 -multiwindow -xkbmodel jp106 -xkblayout jp -clipboard -noprimary -wgl > /dev/null 2>&1 & # for jp-keyboard
  # 	  "$command_path" :0 -multiwindow -clipboard -noprimary -wgl > /dev/null 2>&1 & # for us-keyboard
  #   fi
  # )
  # alias emacs="NO_AT_BRIDGE=1 LIBGL_ALWAYS_INDIRECT=1 emacs"
  alias emacs="DISPLAY=:00 XLIB_SKIP_ARGB_VISUALS=1 NO_AT_BRIDGE=1 LIBGL_ALWAYS_INDIRECT=1 emacs"

  # 必要であれば、以下をアンコメント
  # keychain -q ~/.ssh/id_rsa
  # source ~/.keychain/$HOSTNAME-sh

  # # use git.exe in /mnt/*
  # if which git.exe >/dev/null; then
  #   function git {
  #     if [[ `pwd -P` == /mnt/* ]]; then
  #       git.exe "$@"
  #     else
  #       /usr/bin/git "$@"
  #     fi
  #   }
  # fi

  # # use gh.exe in /mnt/*
  # if which gh.exe >/dev/null; then
  #   function gh {
  #     if [[ `pwd -P` == /mnt/* ]]; then
  #       /mnt/c/Program\ Files/GitHub\ CLI/gh.exe "$@"
  #     else
  #       /usr/bin/gh "$@"
  #     fi
  #   }
  # fi

  # # use tig.exe in /mnt/*
  # if [ -f '/mnt/c/Program Files/Git/usr/bin/tig.exe' ]; then
  #   function tig {
  #     if [[ `pwd -P` == /mnt/* ]]; then
  #       /mnt/c/Program\ Files/Git/usr/bin/tig.exe "$@"
  #     else
  #       /usr/bin/tig "$@"
  #     fi
  #   }
  # fi

  # launch ssh-agent
  SSH_AGENT_FILE="/tmp/ssh_agent"
  [ -f $SSH_AGENT_FILE ] && source $SSH_AGENT_FILE > /dev/null

  if [[ -e $SSH_AUTH_SOCK ]] && ps ${SSH_AGENT_PID} > /dev/null; then
    echo 'found ssh-agent.'
  else
    echo 'start ssh-agent.'
    ssh-agent > $SSH_AGENT_FILE
    cat $SSH_AGENT_FILE
    [ -f $SSH_AGENT_FILE ] && source $SSH_AGENT_FILE > /dev/null
  fi

  function mount-another-distribution-filesystem {
    DISTRIBUTION=$(wsl.exe -l -v | iconv -fUTF16LE | cut -b3- | peco | awk '{print $1}')
    wsl.exe -d ${DISTRIBUTION} -u root mkdir /mnt/wsl/${DISTRIBUTION}
    wsl.exe -d ${DISTRIBUTION} -u root mount --bind / /mnt/wsl/${DISTRIBUTION}
  }
fi

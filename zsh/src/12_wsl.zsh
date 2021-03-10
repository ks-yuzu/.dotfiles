# WSL 上のみ実行
if [[ `uname -a` =~ "Linux.*microsoft" ]]; then
  if [ "$INSIDE_EMACS" ]; then
    TERM=eterm-color
  fi

  umask 022
  export DISPLAY=localhost:0.0

  (
    command_path="/mnt/c/Program Files/VcXsrv/vcxsrv.exe"
    command_name=$(basename "$command_path")

    if ! tasklist.exe 2> /dev/null | fgrep -q "$command_name"; then
      # "$command_path" :0 -multiwindow -xkbmodel jp106 -xkblayout jp -clipboard -noprimary -wgl > /dev/null 2>&1 & # for jp-keyboard
  	  "$command_path" :0 -multiwindow -clipboard -noprimary -wgl > /dev/null 2>&1 & # for us-keyboard
    fi
  )
  alias emacs="NO_AT_BRIDGE=1 LIBGL_ALWAYS_INDIRECT=1 emacs"

  # 必要であれば、以下をアンコメント
  # keychain -q ~/.ssh/id_rsa
  # source ~/.keychain/$HOSTNAME-sh
fi


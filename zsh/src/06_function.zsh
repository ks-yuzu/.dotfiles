function start-emacs {
  if ps aux | grep -q '[e]macs'; then
    echo -n 'Found emacs process. Create another process ? [Y/n] '
    read ans
    case $ans in
      "" | "y" | "Y" | "yes" | "Yes" | "YES" ) :        ;;
      *                                      ) return 1 ;;
    esac
  fi

  SELF_IP=$(ip a | grep eth0: -A2 | tail -n1 | awk '{print $2}' | cut -d/ -f1)
  HOST_IP=$(ip route | awk '/^default/ {print $3; exit}')
  #HOST_IP=$(ipconfig.exe | grep IPv4 | tac | peco --select-1 | grep -v $HOST_IP | rev | awk '{print $1}' | rev | sed 's/\r//g') # workaround: 外から
  HOST_IP=$(ipconfig.exe | nkf -w | grep IPv4 | tac | grep -v $HOST_IP | peco --select-1 | rev | awk '{print $1}' | rev | sed 's/\r//g') # workaround: 外から
  
  export DISPLAY="${HOST_IP}:00"; echo $DISPLAY
  cmd.exe /c set DISPLAY=127.0.0.1:0.0\& "C:\Program Files\VcXsrv\xhost.exe" +${SELF_IP}
  
  #(ps aux | grep -q '[e]macs') && : || (emacs &)
  XLIB_SKIP_ARGB_VISUALS=1 NO_AT_BRIDGE=1 LIBGL_ALWAYS_INDIRECT=1 emacs &
}

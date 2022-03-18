function start-emacs {
  SELF_IP=$(ip a | grep eth0: -A2 | tail -n1 | awk '{print $2}' | cut -d/ -f1)
  HOST_IP=$(ip route | awk '/^default/ {print $3; exit}')
  #HOST_IP=$(ipconfig.exe | grep IPv4 | tac | peco --select-1 | grep -v $HOST_IP | rev | awk '{print $1}' | rev | sed 's/\r//g') # workaround: 外から
  HOST_IP=$(ipconfig.exe | nkf -w | grep IPv4 | tac | peco --select-1 | grep -v $HOST_IP | rev | awk '{print $1}' | rev | sed 's/\r//g') # workaround: 外から
  
  export DISPLAY="${HOST_IP}:00"; echo $DISPLAY
  cmd.exe /c set DISPLAY=127.0.0.1:0.0\& "C:\Program Files\VcXsrv\xhost.exe" +${SELF_IP}
  
  (ps aux | grep -q '[e]macs') && : || (emacs &)
  #emacs --debug-init &
}

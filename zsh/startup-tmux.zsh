## Start tmux automatically on ssh shell
# https://gist.github.com/ABCanG/11bfcff22a0633600aefbb01550b8e38

if [[ -n "${REMOTEHOST}${SSH_CONNECTION}" && -z "$TMUX" && -z "$STY" ]] && type tmux >/dev/null 2>&1; then
    function confirm {
        MSG=$1
        while :
        do
            echo -n "${MSG} [Y/n]: "
            read ans
            case $ans in
                "" | "y" | "Y" | "yes" | "Yes" | "YES" ) return 0 ;;
                *                                      ) return 1 ;;
            esac
        done
    }
    option=""
    if tmux has-session && tmux list-sessions; then
        option="attach"
    fi
    tmux $option && confirm "exit?" && exit
fi

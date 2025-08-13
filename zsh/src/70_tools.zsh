function pcolor()
{
    for ((f = 0; f < 255; f++)); do
        printf "\e[38;5;%dm %3d*■\e[m" $f $f
        if [[ $f%8 -eq 7 ]] then
            printf "\n"
        fi
        done
    echo
}

function battery-pc()
{
	local percentage=$(cat /sys/class/power_supply/BAT1/uevent | grep CAPACITY= | cut -d = -f2)
	echo "Battery : $percentage%"
}

function cc5()
{
    perl -E "print ($*)"
}


function mdisp()
{
    selected=$(
		/bin/cat <<EOF |
[ built-in | HDMI ] xrandr --output eDP-1 --auto --output DP-1 --auto --right-of eDP-1
[ HDMI | built-in ] xrandr --output DP-1 --auto --output eDP-1 --auto --right-of DP-1
[    same (HDMI)  ] xrandr --output DP-1 --auto --same-as eDP-1
[     HDMI off    ] xrandr --output DP-1 --off
[ built-in | VGA  ] xrandr --output eDP-1 --auto --output DP-2 --auto --right-of eDP-1
[  VGA | built-in ] xrandr --output DP-2 --auto --output eDP-1 --auto --right-of DP-2
[    same  (VGA)  ] xrandr --output DP-2 --auto --same-as eDP-1
[     VGA  off    ] xrandr --output DP-2 --off
[  VGA  FULL-HD   ] xrandr --addmode DP-2 1920x1080
[  HDMI FULL-HD   ] xrandr --addmode DP-1 1920x1080
EOF
		peco )

	BUFFER="$(echo "$selected" | sed "s/^\[[^]]*\] *//g")"

    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N mdisp
bindkey '^x^m' mdisp


function set-brightness-usage()
{
	echo "usage:" >&2
	echo "   set-brightness <value>" >&2
	echo "   <value> is an integer between 20 and 100." >&2
	return
}

function set-brightness()
{
	prefix="/sys/class/backlight/intel_backlight"

	if [ ! -e ${prefix}/max_brightness ]; then
		echo 'This script does not work. $prefix is wrong.'
		return
	fi

	## check argument
	if [ -z "${@}" ]; then
		set-brightness-usage
		return
	fi

	## Parse the first argument. (Non-numeric : zero)
	value=$(echo ${1:?} | awk '{print $1*1}')
	if [ ${value} -gt 100 -o ${value} -lt 20 ]; then
		set-brightness-usage
		return
	fi

	MAX_VALUE=$(cat ${prefix}/max_brightness)
	value=$(echo "${MAX_VALUE} * ${value} / 100" | bc)

	echo ${value} | sudo tee ${prefix}/brightness >/dev/null
}



function mount-usb-exfat()
{
    mount -t "exfat" -o "uhelper=udisks2,nodev,nosuid,uid=1000,gid=1000,iocharset=utf8,namecase=0,errors=remount-ro,umask=0077" "/dev/sdb1" "/mnt/usb"
}

function mount-usb-fat32()
{
    mount -t "fat32" -o "uhelper=udisks2,nodev,nosuid,uid=1000,gid=1000,iocharset=utf8,namecase=0,errors=remount-ro,umask=0077" "/dev/sdb1" "/mnt/usb"
}

function mount-usb-ntfs()
{
    mount -t "ntfs" -o "uhelper=udisks2,nodev,nosuid,uid=1000,gid=1000,iocharset=utf8,namecase=0,errors=remount-ro,umask=0077" "/dev/sdb1" "/mnt/usb"
}

function win10()
{
    remmina &
    sudo kvm -hda ~/kvm/win10_x64.qcow2 -boot c -m 2048 -vnc :0 -monitor stdio -usbdevice tablet
}

# function tree()
# {
#     pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'
# }

function dict()
{
    hw -A 1 -w --color --no-line-number $1 ~/dicts/gene-utf8.txt | head | sed -e 's/^.*://g'
}

function lock()
{
    dm-tool loack
}


# linux のディレクトリパスを短縮する
# - 各階層のディレクトリ名を指定した文字数で truncate する
# - git リポジトリルート (直下に .git がある) の場合は truncate しない
# - kustomize 用のディレクトリ内 (bases/, components/, overlays/ の配下) では truncate しない
function shorten-path()
{
  local input=${1:-$(pwd)}
  local length=${2:-3}
  # focused_path=
  # short_path=

  # IFS=/ read -rA DIRS <<<$(echo ${1:-$(pwd)} | sed -e "s|^${HOME}|~|")
  # set -- $DIRS
  # while [ $# -gt 0 ]; do
  #   dir="$1"
  #   shift

  #   if [[ "$dir" = '~' ]]; then
  #     focused_path="${HOME}"
  #     short_path='~'
  #   else
  #     focused_path="${focused_path}/${dir}"

  #     if [[ -e "${focused_path}/.git" || $# -eq 0 ]]; then
  #       short_path="${short_path}/${dir}"
  #     else
  #       short_path="${short_path}/${dir:0:${length}}"
  #     fi
  #   fi

  #   # echo "$focused_path - $short_path"
  # done

  # echo "$short_path"


  ## Split the path into segments
  local abs=${input:A}
  local rest=$abs
  local prefix=''
  if [[ "$abs" == "$HOME" || "$abs" == "${HOME}/"* ]]; then
    prefix='~'
    rest="${abs#$HOME}"
  fi
  rest="${rest#/}" # remove leading slash
  local segs=("$prefix" ${(s:/:)rest})

  local git_root_abs=""
  if (( $+commands[git] )); then
    if command git -C "$abs" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git_root_abs="$(command git -C "$abs" rev-parse --show-toplevel 2>/dev/null)"
      git_root_abs="${git_root_abs:A}"
    fi
  fi

  ## Build short path
  local -a result
  local keep_recursive=0

  local seg
  local curr
  for seg in "${segs[@]}"; do
    curr="${curr}/${seg}"

    local keep=${keep_recursive}
    if [[ "$seg" == 'bases' || "$seg" == 'components' || "$seg" == 'overlays' ]]; then
      keep=1
      keep_recursive=1
    fi

    if [[ -n "$git_root_abs" && "${curr:A}" == "$git_root_abs" ]]; then
      keep=1
    fi

    if (( keep )); then
      result+=("$seg")
    else
      result+=("${seg:0:$length}")
    fi
  done

  echo "${(j:/:)result}"
}

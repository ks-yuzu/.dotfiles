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

function cc()
{
    if type perl6 > /dev/null 2>&1; then
        perl6 -e "say ($*)"
    else
        perl -E "print ($*)"
    fi
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


function bak()
{
	if [ ! -e $1 ]; then
		echo "[error] $1 does not exist."
		return -1;
	fi

	local i=1
	while [ $i -lt 100 ]; do
		local num=$i
		if [ $num -eq 1 ];then
			num=''
		fi

		if [ -e $1.bak$num ]; then
			i=$(( i + 1 ))	  
		else
			break;
		fi;
	done

	if [ $i -eq '1' ];then
		i=''
	fi

	cp -r $1 $1.bak$i
}


function set-brightness-usage()
{
	echo "usage:" >&2
	echo "   setBrightness <value>" >&2
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
		setBrightness-usage
		return
	fi

	## Parse the first argument. (Non-numeric : zero)
	value=$(echo ${1:?} | awk '{print $1*1}')
	if [ ${value} -gt 100 -o ${value} -lt 20 ]; then
		setBrightness-usage
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

function task()
{
    less
}

function tree()
{
    pwd;find . | sort | sed '1d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'
}

function cal-year()
{
    cal $(date --iso-8601 | perl -aF- -e 'print $F[0]');
}

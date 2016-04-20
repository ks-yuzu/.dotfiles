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

function kscproxy()
{
	export http_proxy="http://proxy.ksc.kwansei.ac.jp:8080"
	export https_proxy="https://proxy.ksc.kwansei.ac.jp:8080"
}


function cc()
{
	perl -E "print ($*)"
}

function mdisp()
{
    selected=$(
		cat <<EOF |
[ built-in | HDMI ] xrandr --output eDP1 --auto --output HDMI1 --auto --right-of eDP1
[ HDMI | built-in ] xrandr --output HDMI1 --auto --output eDP1 --auto --right-of HDMI1
[    same (HDMI)  ] xrandr --output HDMI1 --auto --same-as eDP1
[ built-in | VGA  ] xrandr --output eDP1 --auto --output DP1 --auto --right-of eDP1
[  VGA | built-in ] xrandr --output DP1 --auto --output eDP1 --auto --right-of DP1
[    same  (VGA)  ] xrandr --output DP1 --auto --same-as eDP1
[     HDMI off    ] xrandr --output HDMI1 --off
[     VGA  off    ] xrandr --output DP1 --off
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

function inas()
{
	if [ $(mount -v | grep ishiuraLab-nas | wc -l)  -eq '0' ];then
		sudo mount -t cifs //192.168.0.16/disk1 /mnt/ishiuraLab-nas/ \
			-o iocharset=utf8,username=root,password=snoopy2015,file_mode=0755,dir_mode=0755
	fi
	cd /mnt/ishiuraLab-nas/

#	exec "/bin/zsh --exec \"trap 'uinas' EXIT\""
}

function uinas()
{
	if [ $(pwd | grep ishiuraLab-nas | wc -l)  -eq '1' ];then
		cd
	fi
	sudo umount /mnt/ishiuraLab-nas/
	
	touch /tmp/test2.txt
}

function nothing()
{
	exit

	ls /dev/sd* | grep -v 'sda' | peco
	sudo fdisk -l /dev/sdb
}

function setBrightness-usage()
{
	echo "usage:" >&2
	echo "   setBrightness <value>" >&2
	echo "   <value> is an integer between 20 and 100." >&2
	return
}

function setBrightness()
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

function texcompile()
{
    basename=$1                 # tex-file name
    filename=${basename%.*}     # no suffix

    if [ $(file $basename | grep UTF-8 | wc -l) -lt 1 ]; then
        echo '[   convert to UTF-8   ]'
        nkf -w --overwrite $basename
    else
        echo '[ check encode (UTF-8) ]'
    fi

    if [ -f ${filename}.tex ]; then
        if [ -f /tmp/$filename.tex ] && rm -f /tmp/${filename}.tex
        cp ${filename}.tex /tmp
        pushd > /dev/null
        cd /tmp > /dev/null
        platex ${filename}.tex  > /dev/null     # tex -> dvi
        echo '[ generate tex -> dvi  ]'
    else
        echo "file : '${filename}.tex' does not exist."
        return
    fi
 
    if [ -f ${filename}.dvi ]; then
        dvipdfmx ${filename}.dvi 2> /dev/null   # dvi -> pdf
        echo '[ generate dvi -> pdf  ]'
    else
        echo "file : '/tmp/${filename}.dvi' does not exist."
        return
    fi
 
    if [ -f ${filename}.pdf ]; then
        popd > /dev/null 2>&1
        rm -f ${filename}.pdf 2> /dev/null
        cp /tmp/${filename}.pdf ./
        gnome-open ${filename}.pdf > /dev/null 2>&1 # open pdf
        echo '[  open generated pdf  ]'
    else
        echo "file : '/tmp/${filename}.pdf' does not exist."
    fi
}

# commnads for lab

alias labvpn='sudo /usr/sbin/openvpn /etc/openvpn/client.ovpn &'


function gitlab-open
{
    if [ $(ps aux | grep ssh | grep 192.218.172.60:8080 | wc -l) -eq 0 ]; then
        ssh -fN -L9999:192.218.172.60:8080 60
    fi

    firefox localhost:9999
}

function gitlab-close
{
    local pid=$(ps -aux | grep ssh | grep 192.218.172.60:8080 | peco | awk '{print $2}' )
    kill $pid && echo killed $pid
}


##### scripts for nas #####

export LAB_NAS_MOUNT_POINT_LOCAL='/mnt/labnas'

function inas()
{
	if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_LOCAL | wc -l)  -eq '0' ];then
        sudo mkdir $LAB_NAS_MOUNT_POINT_LOCAL
		sudo mount -t cifs //192.168.0.16/disk1 $LAB_NAS_MOUNT_POINT_LOCAL \
			 -o iocharset=utf8,username=user,password=pass,file_mode=0755,dir_mode=0755,uid=$(id -u),gid=$(id -g)
	fi
	cd $LAB_NAS_MOUNT_POINT_LOCAL
}

function uinas()
{
	if [ $(pwd | grep $LAB_NAS_MOUNT_POINT_LOCAL | wc -l)  -eq '1' ];then
		cd > /dev/null
	fi

    if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_LOCAL | wc -l)  -ge '1' ];then
	    sudo umount $LAB_NAS_MOUNT_POINT_LOCAL
    fi

    if [ -d $LAB_NAS_MOUNT_POINT_LOCAL ] && sudo rmdir $LAB_NAS_MOUNT_POINT_LOCAL
}


##### scripts for sshfs #####

export LAB_NAS_MOUNT_POINT_SSH='/mnt/ssh-labnas'
export LAB_SERVER10_KEY_PATH='/home/yuzu/.ssh/ex_computer/id_ed25519_excomputer'
export LAB_SERVER_IP='192.218.172.58'
#export LAB_SERVER_IP='192.168.0.10'

function sshinas()
{
    if [ ! -d $LAB_NAS_MOUNT_POINT_SSH ] && sudo mkdir $LAB_NAS_MOUNT_POINT_SSH
    
    if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_SSH | wc -l)  -eq '0' ];then
        sudo sshfs \
             yuzu@$LAB_SERVER_IP:$LAB_NAS_MOUNT_POINT_LOCAL \
             $LAB_NAS_MOUNT_POINT_SSH \
             -o uid=$(id -u),gid=$(id -g),allow_other,IdentityFile=$LAB_SERVER10_KEY_PATH
    fi
    cd $LAB_NAS_MOUNT_POINT_SSH
}

function usshinas()
{
	if [ $(pwd | grep $LAB_NAS_MOUNT_POINT_SSH | wc -l)  -eq '1' ];then
		cd > /dev/null
	fi

    if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_LOCAL | wc -l)  -ge '1' ];then
	    sudo umount $LAB_NAS_MOUNT_POINT_SSH
    fi

    if [ -d $LAB_NAS_MOUNT_POINT_SSH ] && sudo rmdir $LAB_NAS_MOUNT_POINT_SSH
}

# commnads for lab

##### scripts for vpn #####
alias labvpn='sudo /usr/sbin/openvpn /etc/openvpn/client.ovpn &'


##### scripts for gitlab #####
function gitlab-open
{
    if [ $(ps aux | grep ssh | grep 192.218.172.56:80 | wc -l) -eq 0 ]; then
        ssh -fN -L9999:192.218.172.56:80 lab60
    fi

    firefox localhost:9999
}

function gitlab-close
{
    local pid=$(ps -aux | grep ssh | grep 192.218.172.56:80 | peco | awk '{print $2}' )
    if [ $pid != "" ]; then
       kill $pid && echo killed $pid
    fi
}


##### scripts for nas #####
export LAB_NAS_MOUNT_POINT_LOCAL='/mnt/labnas'

function inas()
{
    # Make a mount point directory
    if [ ! -d $LAB_NAS_MOUNT_POINT_LOCAL ]; then
            sudo mkdir $LAB_NAS_MOUNT_POINT_LOCAL
            echo "Made a directory '$LAB_NAS_MOUNT_POINT_LOCAL'."
    fi

    # mount
	if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_LOCAL | wc -l)  -eq '0' ];then
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


##### scripts for nas with sshfs #####
export SSH_USER='yuzu'
export LAB_NAS_MOUNT_POINT_SSH='/mnt/ssh-labnas'
export LAB_SERVER10_KEY_PATH="$HOME/.ssh/ex_computer/id_ed25519_excomputer"
export LAB_SERVER_IP='192.218.172.58'
#export LAB_SERVER_IP='192.168.0.10'

function sshinas()
{
    if [ ! -d $LAB_NAS_MOUNT_POINT_SSH ]; then
        sudo mkdir $LAB_NAS_MOUNT_POINT_SSH
        echo "Made a mount point directory '$LAB_NAS_MOUNT_POINT_SSH'"
    fi
    
    if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_SSH | wc -l)  -eq '0' ];then
        sudo sshfs \
             ${SSH_USER}@${LAB_SERVER_IP}:${LAB_NAS_MOUNT_POINT_LOCAL} \
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

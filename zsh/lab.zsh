# commnads for lab

alias labvpn='sudo /usr/sbin/openvpn /etc/openvpn/client.ovpn &'


##### scripts for nas #####

export LAB_NAS_MOUNT_POINT_LOCAL='/mnt/labnas'

function inas()
{
	if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_LOCAL | wc -l)  -eq '0' ];then
        sudo mkdir $LAB_NAS_MOUNT_POINT_LOCAL
		sudo mount -t cifs //192.168.0.16/disk1 $LAB_NAS_MOUNT_POINT_LOCAL \
			 -o iocharset=utf8,username=root,password=snoopy2015,file_mode=0755,dir_mode=0755,uid=$(id -u),gid=$(id -g)
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
        sudo rmdir $LAB_NAS_MOUNT_POINT_LOCAL
    fi
}


##### scripts for sshfs #####

export LAB_NAS_MOUNT_POINT_SSH='/mnt/ssh-labnas'

function sshinas()
{
    sudo mkdir $LAB_NAS_MOUNT_POINT_SSH
    if [ $(mount -v | grep $LAB_NAS_MOUNT_POINT_SSH | wc -l)  -eq '0' ];then
        sudo sshfs \
             yuzu@192.168.0.10:$LAB_NAS_MOUNT_POINT_LOCAL \
             $LAB_NAS_MOUNT_POINT_SSH \
             -o uid=$(id -u),gid=$(id -g),allow_other,IdentityFile=/home/yuzu/.ssh/ex_computer/id_ed25519_excomputer
    fi
    cd /mnt/ssh-labnas
}

function usshinas()
{
	if [ $(pwd | grep $LAB_NAS_MOUNT_POINT_SSH | wc -l)  -eq '1' ];then
		cd > /dev/null
	fi
	sudo umount $LAB_NAS_MOUNT_POINT_SSH
    sudo rmdir $LAB_NAS_MOUNT_POINT_SSH
}

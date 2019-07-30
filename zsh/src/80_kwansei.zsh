# commnads for kwansei

function kwansei-z()
{
    KWANSEI_Z_MOUNT_POINT_LOCAL='/mnt/kwansei-z'
    
    # Make a mount point directory
    if [ ! -d $KWANSEI_Z_MOUNT_POINT_LOCAL ]; then
        sudo mkdir $KWANSEI_Z_MOUNT_POINT_LOCAL
        echo "Made a directory '$KWANSEI_Z_MOUNT_POINT_LOCAL'."
    fi

    echo 'test';
    
    # mount
	if [ $(mount -v | grep $KWANSEI_Z_MOUNT_POINT_LOCAL | wc -l)  -eq '0' ]; then
        sudo mount /mnt/kwansei-z
    else
        echo 'already mounted'
	fi

	cd $KWANSEI_Z_MOUNT_POINT_LOCAL
}


function kscproxy()
{
	export http_proxy="http://proxy.ksc.kwansei.ac.jp:8080"
	export https_proxy="https://proxy.ksc.kwansei.ac.jp:8080"
}

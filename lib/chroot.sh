#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
. $DIR/libmount.sh


mount_image $1 
chroot_mount

echo Chrooting into the root dir. Press ctrl-d to exit and unmont
chroot root

chroot_umount
unmount_image

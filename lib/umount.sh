#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
. $DIR/libmount.sh
echo $DIR

chroot_umount
unmount_image  
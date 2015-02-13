#!/bin/bash
set -x
set -e
DIR="$( cd "$( dirname "$0" )" && pwd )"
. $DIR/libmount.sh
. $DIR/libtools.sh
echo $DIR

chroot_umount
unmount_image

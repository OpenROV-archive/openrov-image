#!/bin/bash
export DIR=${PWD#}

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

checkroot

chroot_umount
unmount_image

rm -rf  ubuntu-*armhf-* output work/packages work/step_03 work/step_04

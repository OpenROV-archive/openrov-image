#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
. $DIR/libmount.sh
. $DIR/libtools.sh

checkroot

if [ "$1" = "" ]; then

	echo "Please pass the name of the disk image you want to chroot into!"
	exit 1
fi

if [ "$1" = "-h" ]; then
	echo "Usage: chroot.sh </path/to/image.img> [<command file to execute in chroot>]"
fi

mount_image $1 
chroot_mount

if [ "$2" != "" ]; then
	if [ ! -f "$2" ]; then
		echo "Specified command file $2 does not exist!"
	fi
	cp "$2" root/tmp/
	command_file=$(basename $2)
	chroot_command="sh /tmp/${command_file}"
else
	echo Chrooting into the root dir. Press ctrl-d to exit and unmont
fi

chroot root $chroot_command

if [ -f "$2" ]; then
	rm "$2"
fi

chroot_umount
unmount_image

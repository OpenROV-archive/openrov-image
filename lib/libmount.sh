#!/bin/bash

	function mount_image {
		echo mounting image
		
		media_loop=$(losetup -f || true)
		
		if [ ! -d root ]; then 
			mkdir root
		fi
		if [ ! -d boot ]; then
			mkdir boot
		fi

		if [ ! "${media_loop}" ] ; then
			echo "losetup -f failed"
			echo "Unmount some via: [sudo losetup -a]"
			echo "-----------------------------"
			losetup -a
			echo "sudo kpartx -d /dev/loopX ; sudo losetup -d /dev/loopX"
			echo "-----------------------------"
			exit
		fi

		losetup ${media_loop} $1

		kpartx -av ${media_loop}
		sleep 1
		sync
		test_loop=$(echo ${media_loop} | awk -F'/' '{print $3}')

		if [ -e /dev/mapper/${test_loop}p1 ] && [ -e /dev/mapper/${test_loop}p2 ] ; then
			export media_prefix="/dev/mapper/${test_loop}p"
			export ROOT_media=${media_prefix}2
			export BOOT_media=${media_prefix}1
		else
			ls -lh /dev/mapper/
			echo "There was an error mounting the image! Not sure what to do."
			exit 1
		fi
		mount $ROOT_media root
		mount $BOOT_media boot
		mount $BOOT_media root/boot

		echo Mounted ROOT partition at ${PWD#}/root
		echo Mounted BOOT partition at ${PWD#}/boot
	}

function unmount_image {
	root_dir=${PWD#}/root
	boot_dir=${PWD#}/boot

	# try to find the mapped dir
	loop_device=$(mount | grep $root_dir | grep -o '/dev/mapper/loop.' | grep -o 'loop.')


	umount $root_dir/boot
	umount $root_dir
	umount $boot_dir

	kpartx -d /dev/${loop_device}
	losetup -d /dev/${loop_device}
}

function chroot_mount {
	root_dir=${PWD#}/root

	echo Mounting system directories from root: $root_dir
	mount --bind /dev/ $root_dir/dev/
	mount --bind /proc/ $root_dir/proc/
	mount --bind /sys/ $root_dir/sys/
	mount --bind /run/ $root_dir/run/
	mount --bind /etc/resolv.conf $root_dir/etc/resolv.conf
        mount devpts $root_dir/dev/pts -t devpts

}

function chroot_umount {
	echo Unmounting system directories
	root_dir=${PWD#}/root
	umount $root_dir/dev/pts
	umount $root_dir/etc/resolv.conf
	umount $root_dir/run
	umount $root_dir/sys
	umount $root_dir/proc
	umount $root_dir/dev

}

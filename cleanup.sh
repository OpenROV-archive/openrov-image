#!/bin/sh

if [ -d "root" ]; then
	# make sure the directories are unmounted
	umount root/etc/resolv.conf
	umount root/run
	umount root/sys
	umount root/proc
	umount root/dev

	umount root	
fi

if [ -d "root" ]; then
	umount boot
fi
rm -rf boot root ubuntu-*armhf-* work

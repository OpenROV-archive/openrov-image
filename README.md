openrov-image
=============

Get and install the OpenROV disk image
======================================

To get the latest version of the OpenROV disk image for your ROV, you will need a Linux box (or virtual machine) and a micro-sd card with at least 2 GB.
A windows based solution will follow.

To download:

	wget http://wp.nu/openrov-image-0

That will give you an file like _ubuntu-12.04-r8-minimal-armhf-YYYY-MM-DD.tar.xz_.

	tar xJf ubuntu-12.04-r7-minimal-armhf-YYYY-MM-DD.tar.xz
	cd ubuntu-12.04-r7-minimal-armhf-YYYY-MM-DD

If you don't know the location of your SD card:
	
	sudo ./setup_sdcard.sh --probe-mmc

You should see something like
	
	Are you sure? I Don't see [/dev/idontknow], here is what I do see...

	fdisk -l:
	Disk /dev/sda: 500.1 GB, 500107862016 bytes <- x86 Root Drive
	Disk /dev/mmcblk0: 3957 MB, 3957325824 bytes <- MMC/SD card

	mount:
	/dev/sda1 on / type ext4 (rw,errors=remount-ro,commit=0) <- x86 Root Partition
	
In this example, we can see via mount, _/dev/sda1_ is the x86 rootfs, therefore _/dev/mmcblk0_ is the other drive in the system, which is the MMC/SD card that was inserted and should be used by ./setup_sdcard.sh...

Install image:

	sudo ./setup_sdcard.sh --mmc /dev/sdX --uboot "bone"

This will write the image onto your sd-card.

Starting the OpenROV
--------------------

Just put the newly created sd-card into your BeagleBone.
To see the output, connect the BeagleBone to your computer via the USB cable and open a terminal.

	picocom -b 115200 /dev/ttyUSBx

OR

Find the IP address the BeagleBone got from your dhcp server and use ssh to connect:
	
	ssh rov@123.123.123.123

On the first boot it will take some time (like a few minutes) to fully setup the installation.

Once you see the logon screen, use:

	username: rov
	password: OpenROV



Build your own disk image
=========================

Automated BeagleBone image creation for OpenROV

If you got a fresh Ubuntu install, you can execute 'setup-system.sh' to fullfil all the requirements.
But you might want to check what it installs, quite a lot...

You will need the ARM compiler toolchain as described here: 
http://elinux.org/Toolchains#Linaro_.28ARM.29


How to build?
-------------

Once you have all what you need (node, cross compilers) you can run:

     ./build.sh


What happens?
-------------

First of all, a directory called 'work' is created.

Then, we get NodeJS from github and patch it so we can compile it for arm.
Once the node is built, it is copied to work/additions/node_deploy.

We get the OpenROV software from github and put it to work/additions/openrov.

Then we get a special fork of the 'omap-image-builder' for OpenROV. 
This project will get a few other things from github and other sources and actually build a complete Ubuntu Image for ARM from scratch.
During that process, we copy what is in the work/additions folder over to the image to /tmp/additions.
Once the image is done (and still mounted through the loopback device' all top level folders in tmp/additions are searched for 'install.sh' files. Every file is executed in turn and can do changes (as root) on the image.




openrov-image
=============

Get and install the OpenROV disk image
======================================

To get the latest version of the OpenROV disk image for your ROV, you will need a Linux box (or virtual machine) and a micro-sd card with at least 2 GB.
A windows based solution will follow.

To download:

	wget https://www.dropbox.com/s/rhiw3lgewfoc44q/ubuntu-12.04-r8-minimal-armhf-2012-11-10.tar.xz?dl=1

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

Once its fully started, you should be able to browse to: http://<IP.OF.THE.ROV>:8080.

The BB tries to get an IP address from your DHCP server. Beside that, it listens on the IP address 192.168.254.1. So, if you connect your BB directly via a network cable, you cann change you PC ip address to 192.168.254.2 or add an additional alias (in linux something like: ifconfig eth0:0 192.168.254.2 up) and you should be able to connect to the BB by:
http://192.168.254.1:8080/

Uploading Arduino Firmware
--------------------------

If you have a OpenROV cape connected to your BeagleBone (if you build your own, make sure you use UART1), you can upload a firmware to Arduino directly from the browser.
In the OpenROV Cockpit there is a Settings page (top left corner). From there you can upload a .ZIP or .tar.gz file containing your Arduino sketch (.ino files with additional .c/h files).

**Right now there is no error reporting on the firmware upload! You always see it seccessful. To check for errors, please look in the OpenROV logfile as explained below.**

Debuging and being in control
-----------------------------

If you wan't to log on to your BB, either connect a USB cable and us:
	
	picocom -b 115200 /dev/ttyUSB1

Or SSH:

	ssh rov@<IP ADDRESS>

Or SSH on the static IP:

	ssh rov@192.168.254.1


Once you see the logon screen, use:

	username: rov
	password: OpenROV

The OpenROV cockpit service writes a logfile to:
	
	/var/log/openrov.log

To Start/Stop the cockpit service use:

	sudo /etc/init.d/openrov start
	sudo /etc/init.d/openrov stop

To manually start the cockpit service use:

	sudo /etc/init.d/openrov stop
	sudo bash
	/opt/node/bin/node /opt/openrov/src/app.js
	


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




openrov-image
=============

For submitting issues, use the primary software repository: https://github.com/OpenROV/openrov-software

Get and install the OpenROV disk image
======================================

To get the latest stable release version of the OpenROV disk image for your ROV, you will need a micro-sd card with at least 2 GB.

The latest disk image is:

**OpenROV-2.5-29.img.7z**

To download, get the file from:

https://github.com/OpenROV/openrov-software/releases/tag/v2.5.0

The image is compressed with _7Zip_ so you have to unzip it first.

*Linux:*

	p7zip -d OpenROV-2.5-29.img.7z

*Windows:*

	Use 7Zip.

Write the image onto you SD card:

*Linux:*

	# Find the right /dev/sdX device. The easiest way is to have a look at the output of _dmesg_ after you plugged in the sd-card.

	dd if=OpenROV-2.5-29.img.7z of=/dev/sdX

*Windows:*

	1. Get the latest version of *Win32DiskImager* from http://sourceforge.net/projects/win32diskimager/files/latest/download
	2. Point the Win32DiskImager to the image file 'OpenROV-2.5-05.img.7z' and the SD card
	3. Press 'Write' and wait till its written to the SD card


Starting the OpenROV
--------------------

Just put the newly created sd-card into your BeagleBone (BB).

**Hint:** The first boot will take a bit longer (the ROV will actually restart) as the root partition is extended to fill the SD card.

Once its fully started, you should be able to browse to: `http://<IP.OF.THE.ROV>:8080`.

The BB will try to get an IP address from your DHCP server. Besides that, it also listens on the IP address `192.168.254.1`.
So, if you connect your BB directly via a network cable, you can change your computers IP address to `192.168.254.2`
or anything on the `.254` subnet (in Linux, something like: `ifconfig eth0:0 192.168.254.2` up) and you should be able to connect to the BB by visiting:
`http://192.168.254.1:8080`

You can also connect the BeagleBone to your computer via USB for testing.
In this case, after you have installed the latest drivers for the BB (http://beagleboard.org/static/beaglebone/latest/README.htm),
you will see a new drive in your Explorer or Linux Desktop. Open that drive and you will see a _START.htm_ file. Open that in Chrome and you will be redirected to:
`http://192.168.7.2:8080`


Cloud9
------

The OpenROV image comes with *Cloud9*, a web based integrated development environment. You can access Cloud9 via:

`http://192.168.254.1:3131`

Or the IP address assigned to the OpenROV by your router.

The **Username/Password** is: *rov* and *OpenROV*


Debuging and being in control
-----------------------------

If you wan't to log on to your BB, either connect a USB cable and use (from a Linux machine):

	picocom -b 115200 /dev/ttyUSB1

Otherwise, from a Mac you have to use:

	screen `ls /dev/{tty.usb*B,beaglebone-serial}` 115200

From Windows you can use any terminal application and connect to the USB port.

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
	/opt/node/bin/node /opt/openrov/cockpit/src/app.js


Customize the disk image
========================

**This only works on Linux and is only tested on Ubuntu!**
In the _lib_ folder you will find a bunch of scripts that can help you to customize the downloded image:

*mount.sh*
This script creates two directories, _boot_ and _root_ in the current directory.
After it mounts the image via _loopback_ and _kpartx_ you can start to make changes in the mounted image.
Usage:

	./lib/mount.sh <PATH TO OpenROV.img>

*umount.sh*
Unmounts the directories that were mounted with _mount.sh_.
You need to execute this in the directory where the boot and root directories are located.
Usage:

	./lib/umount.sh

*chroot.sh*
This script mounts the image and puts you in an chroot environment. Your environment will look like it does on the BeagleBone.
The commands you execute are actually ARM binaries executed via qemu, so things might be a bit slower.
To exit this environment and to unmount the image, press *ctrl-d*.
Usage:

	./lib/chroot.sh <PATH TO OpenROV.img>

*updatecockpit.sh*
This scripts updates just the OpenROV cockpit and the npm modules.
Usage:

	./lib/updatecockpit.sh <PATH TO OpenROV.img>


Build your own disk image
=========================

The script we use to build our image is _build.sh_.

**This only works on Linux and is only tested on Ubuntu!**

It takes a single argument, the path (on your disk) to one of the demo images from http://elinux.org/BeagleBoardUbuntu.
To get the latest experimental (Ubuntu 13.10) image:

	wget http://rcn-ee.net/deb/rootfs/saucy/ubuntu-saucy-console-armhf-2013-07-22.tar.xz

You will need a recent node installation and cross compilers for ARM on you machine too.

Alternatively...

We have added a vagrant file for easy builds of your own disk images and general access to the cross compiler environment that works across all major OS types.
It has two pre-reqs:

1. [Virtual Box](https://www.virtualbox.org/wiki/Downloads)
2. [Vagrant](http://downloads.vagrantup.com/)

Once they are installed, you simply download this git repo to your local system and from the command-line type:

	vagrant up

The system will automatically spin up a virtual image and load the pre-reqs. To login to it type:

	vagrant ssh

There will be a _/vagrant_ folder in the virtual image that you can go to and run the build command below.
That folder is a shared link to the folder on your local computer.


How to build?
-------------

Once you have eveything you need (node, cross compilers) you can run:

     ./build.sh ../<PATH TO>/ubuntu-saucy-console-armhf-2013-07-22.tar.xz


What happens?
-------------

The demo images come with a script to build an SD card or a disk image.

__First of all__, _build.sh_ creates a disk image with the demo image scripts (_steps/01_build_image.sh_).
The output of this is saved in _work/steps/step_01/_

__Step 2__ is to update the image with the latest Ubuntu packages and install all the required additional packages (_steps/02_update_image.sh_).
The output is saved in _work/steps/step_02/_

__Step 3__ is to get all the other tools we need from their source and compile them.
This is:

- NodeJS
- OpenROV Cockpit
- mjpeg-streamer
- ino (command line arduino)
- dtc (device tree compiler)
- avrdude
- Cloud9
- Samba configuration (network sharing)

Some of these packages are built via a cross compiler on the host machine. Where this is not possible, a chroot environment is used.
For this, the image from _Step 2_ is copied and the software is built and installed on the image.
After compilation/installation the relevent files are packaged in .deb files .

All the scripts to build the softare are to be found in: _steps/step_03/*.sh_

__Step 4__ is to customize the root environment. In this step we install the .deb packages and setup the hostname,
ip address/network configuration, users and other things. Script: _steps/04_customize_image.sh_.

__Step 5__ is to compress the image and calculate the md5 of the image.

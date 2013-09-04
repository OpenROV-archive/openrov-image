openrov-image
=============

Get and install the OpenROV disk image
======================================

To get the latest version of the OpenROV disk image for your ROV, you will need a micro-sd card with at least 2 GB.

The latest disk image is:

**OpenROV-05-09-2013.img.7z**

To download, get the file from:

https://docs.google.com/uc?id=0B-NH5UNY7g7jTGoyN1BBQ09DbVE&export=download

The image is compressed with _7Zip_ so you have to unzip it first.

*Linux:*

	p7zip -d OpenROV-DD-MM-YYY.img.7z

*Windows:*

	Use 7Zip. 

Write the image onto you SD card:

*Linux:*

	Find the right /dev/sdX device. The easiest way is to have a look at the output of _dmesg_ after you plugged in the sd-card.

	dd if=OpenROV-DD-MM-YYYY.img of=/dev/sdX


*Windows:*

	1. Get the latest version of *Win32DiskImager* from https://launchpad.net/win32-image-writer/+download
	2. Point the Win32DiskImager to the image file 'OpenROV-DD-MM-Y theYYY.img' and the SD card
	3. Press 'Write' and wait till its written to the SD card


Starting the OpenROV
--------------------

Just put the newly created sd-card into your BeagleBone.

Once its fully started, you should be able to browse to: http://<IP.OF.THE.ROV>:8080.

The BB tries to get an IP address from your DHCP server. Beside that, it listens on the IP address 192.168.254.1. So, if you connect your BB directly via a network cable, you cann change you PC ip address to 192.168.254.2 or add an additional alias (in linux something like: ifconfig eth0:0 192.168.254.2 up) and you should be able to connect to the BB by:
http://192.168.254.1:8080/

You can as well connect the BeagleBone via USB to your computer for testing.
In this case, given you have installed the latest drivers (http://beagleboard.org/static/beaglebone/latest/README.htm), you will see a new drive in showing in your Explorer or Linux Desktop. Open that drive and you will see a _START.htm_ file. Open that in Chrome and you will be redirected to:
http://192.168.7.2:8080



Uploading Arduino Firmware
--------------------------

**Right now there is no error reporting on the firmware upload! You always see it seccessful. To check for errors, please look in the OpenROV logfile as explained below.**

If you have a OpenROV cape connected to your BeagleBone (if you build your own, make sure you use UART1 and GPIO1_0), you can upload a firmware to Arduino directly from the browser.
In the OpenROV Cockpit there is a Settings page (top right corner). From there you can upload a .ZIP or .tar.gz file containing your Arduino sketch (.ino files with additional .c/h files).

The Arduino upload needs the reset.sh script that is part of the cockpit branch of openrov-software.
https://github.com/OpenROV/openrov-software/blob/cockpit/linux/reset.sh
This script is laid out to use GPIO1_0 in a mode where the GPIO0_1 is on high in the beginning and therefore there is 5V on pin 1 (RESET) on the ATMEGA chip.
On reset, pin1 is pulled to low and the Arduino will reset once pin 1 goes on high again.
**If you built your own cape, make sure you have implement the same behavior! Otherwise you have to change
the reset script accordingly!**


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
	/opt/node/bin/node /opt/openrov/src/app.js
	

Customize the disk image
========================

**This only works on Linux and is only tested on Ubuntu!**
In the _lib_ folder you will find a bunch of scripts that can help you to customize the downloded image:

*mount.sh*
This script mounts creates two directories, boot and root (the directories are created in the current directory).
Then it mounts the image via loopback and kpartx and you can start to do changes in the mounted image.
Usage:

	./lib/mount.sh <PATH TO OpenROV.img>

*umount.sh*
Unmounts the directories that where mounted with 'mount.sh'.
You need to execute this in the directory where the boot and root directories are located
Usage:

	./lib/umount.sh

*chroot.sh*
This script mounts the image and puts you in an chroot environment. Your environment looks like on the BeagleBone.
The commands you execute are actualle ARM binaries executed via qemu, so things might be a bit slower.
To exit this environment and to unmount the image, press *ctrl-d*
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

As a single argument it takes the path (on your disk) to one of the demo images from http://elinux.org/BeagleBoardUbuntu.
To get the latest experimental (Ubuntu 13.10) image:

	wget http://rcn-ee.net/deb/rootfs/saucy/ubuntu-saucy-console-armhf-2013-07-22.tar.xz

You will need a recent node installation and cross compilers for arm on you machine too.

Alternatively...

We have added a vagrant file for easy builds of your own disk images and general access to the cross compiler environment that works across all major O/S types.
It has two pre-reqs:

1. [Virtual Box](https://www.virtualbox.org/wiki/Downloads)
2. [Vagrant](http://downloads.vagrantup.com/)

Once they are installed you simply download this git repo to your local system and from the command-line type:

	vagrant up

The system will automatically spin up a virtual image and load the pre-reqs.  To login to it type:

	vagrant ssh

There will be a /vagrant folder in the virtual image that you can go to and run the build command below. That folder is a shared link to the folder on your local computer.

How to build?
-------------

Once you have all what you need (node, cross compilers) you can run:

     ./build.sh ../<PATH TO>/ubuntu-saucy-console-armhf-2013-07-22.tar.xz


What happens?
-------------

The demo images come with a script to build an SD card or a disk image.

First of all, _build.sh_ creates disk image with the demo image scripts.

Step two is to get all the other tools we need from their source. 
This is: 
	- NodeJS
	- mjpeg-streamer
	- ino (command line arduino)
	- dtc (device tree compiler)
	- avrdude
	- OpenROV

NodeJS is cross compiled on your machine. The other tools will be compiled in a chroot environment.

After NodeJS is compiled we mount the OpenROV.img file that was created by the demo image script via the loopback device and _kpartx_ (to mount the two partitions of the image).

A chroot environment is setup (have a look at ./lib/chroot.sh for more details) and the _lib/customizeroot.sh_ is executed with the new root.


## Root customisation

We update all ubuntu packages that are out of date and install the packages we need for OpenROV.
We compile and install mjpeg-streamer, ino, dtc and avrdude, setup OpenROV and do changes to the system configuration files for networking, dhcp and getting OpenROV Cockpit started when the BB starts.





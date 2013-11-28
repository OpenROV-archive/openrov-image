openrov-image Changelog
=============

## 26/28-11-2013

- Move to staged approach to create image
	- Step 1: build the image from the elinux base image
	- Step 2: Update the image with the latest Ubuntu packages and the needed additional packages
	- Step 3: Build all the software that we need and package them in .DEB packages with the Effing Package manage FPM. The image that is used to compile the pcakages is a copy of the image above. It image will be not distributed
	- Step 4: Customiz the image: Install the packages, modify hostname, network config and users. Create the output image and create a md5 hash
	- Step 5: compress the image and create the md5 hash


## 05-09-2013

- Improve arduino reset when uploading firmware by extending avrdude with a patch
- fix arduino library (for the compilation of the openrov arduino code) by using arduino library code from 1.0.4


## 03-09-2013 

- Updated Cockpit and Arduino code from OpenROV/openrov-software
- Change the default reset pin for the linuxspi in avrdude (OpenROV/openrov-image#22)
- The SPI device is not showing up on the BBB image (OpenROV/openrov-image#21)
- ino tools fails to parse arduino version number in image (OpenROV/openrov-image#20)
- DHCP not working: Typo (OpenROV/openrov-image#19)
- Update the avrdude make to set the Have_Linux_GPIO option (OpenROV/openrov-image#18))


## 23-08-2013

- SD Card can be used in different BB (fixes issue #12)
- Image works for BBB (fixes issue #15)
- Network issues with static IP solved (fixes issue #11)
- Personalised autorun image and device name (when you put the sd card in your computer or connect the BB via USB)
- When connected via USB: START.htm on the disk drive redirects to the cockpit
- Ubuntu Saucy Salamander based on demo image ubuntu-saucy-console-armhf-2013-07-22.tar.xz
- NodeJS 0.10.17
- dtc (device tree compiler)
- avrdude with linux SPI programmer (fixes issue #16)


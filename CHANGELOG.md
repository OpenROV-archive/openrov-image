openrov-image Changelog
=============

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


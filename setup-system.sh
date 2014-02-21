#!/bin/sh

sudo apt-get install dosfstools git-core kpartx u-boot-tools wget parted gcc g++ make qemu qemu-user-static libglib2.0-dev git nodejs npm fakeroot libjpeg-dev cpp-arm-linux-gnueabihf g++-arm-linux-gnueabihf

sudo update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10
sudo update-alternatives --install /bin/sh sh /bin/bash 10

sudo apt-get install rubygems
sudo gem install fpm




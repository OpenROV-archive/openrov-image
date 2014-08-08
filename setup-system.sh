#!/bin/sh
sudo apt-get update
sudo apt-get install -y dosfstools git-core kpartx u-boot-tools wget parted gcc g++ make qemu qemu-user-static libglib2.0-dev git nodejs npm fakeroot libjpeg-dev cpp-arm-linux-gnueabihf g++-arm-linux-gnueabihf p7zip p7zip-full

sudo update-alternatives --install -y "/usr/bin/node" "node" "/usr/bin/nodejs" 10
sudo update-alternatives --install -y "/bin/sh" "sh" "/bin/bash" 10

sudo apt-get install -y rubygems
sudo gem install fpm

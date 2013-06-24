#!/bin/sh
sudo apt-get install python-software-properties

sudo add-apt-repository ppa:richarvey/nodejs
sudo add-apt-repository ppa:linaro-maintainers/toolchain
sudo apt-get update

sudo apt-get install gcc g++ make qemu qemu-user-static libglib2.0-dev git nodejs npm gcc-4.6-arm-linux-gnueabihf g++-4.6-arm-linux-gnueabihf fakeroot libjpeg-dev



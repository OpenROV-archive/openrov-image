#!/bin/sh

sudo add-apt-repository ppa:richarvey/nodejs
sudo add-apt-repository ppa:linaro-maintainers/toolchain
sudo apt-get update

sudo apt-get install gcc g++ make qemu qemu-user-static libglib2.0-dev git nodejs npm gcc-arm-linux-gnueabi g++-arm-linux-gnueabi fakeroot



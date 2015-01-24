#!/bin/bash
sudo apt-get update
sudo apt-get install -y dosfstools git-core kpartx u-boot-tools wget parted gcc g++ make qemu qemu-user-static libglib2.0-dev git nodejs npm fakeroot libjpeg-dev cpp-arm-linux-gnueabihf g++-arm-linux-gnueabihf p7zip p7zip-full nodejs-legacy ruby1.9.1-dev

sudo update-alternatives --install "/usr/bin/node" "node" "/usr/bin/nodejs" 10
sudo update-alternatives --install "/bin/sh" "sh" "/bin/bash" 10

npm install -g node-pre-gyp

sudo gem install fpm

sudo apt-get -y install docker.io
sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io

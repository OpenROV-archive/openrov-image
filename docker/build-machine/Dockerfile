FROM ubuntu:14.04
MAINTAINER Dominik Fretz, dominik@openrov.com

# installing packages needed for cross compiling and image creation
RUN sudo apt-get update
RUN sudo apt-get install -y dosfstools git-core kpartx u-boot-tools wget parted gcc g++ make qemu qemu-user-static libglib2.0-dev git nodejs npm fakeroot libjpeg-dev cpp-arm-linux-gnueabihf g++-arm-linux-gnueabihf p7zip p7zip-full nodejs-legacy ruby1.9.1-dev

RUN sudo update-alternatives --install "/usr/bin/node" "node" "/usr/bin/nodejs" 10
RUN sudo update-alternatives --install "/bin/sh" "sh" "/bin/bash" 10

RUN npm install -g node-pre-gyp

RUN sudo gem install fpm

RUN sudo apt-get -y install docker.io
RUN sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
RUN sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io


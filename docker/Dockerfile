FROM saltstack/ubuntu-13.10

# installing packages needed for cross compiling and image creation
RUN apt-get install -y dosfstools git-core kpartx u-boot-tools wget parted gcc g++ make qemu qemu-user-static libglib2.0-dev git nodejs npm fakeroot libjpeg-dev cpp-arm-linux-gnueabihf g++-arm-linux-gnueabihf rubygems

# Fixing alternatives (command line apps)
RUN update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10
RUN update-alternatives --install /bin/sh sh /bin/bash 10

# install fpm, a tool to create debian packages (and more)
RUN gem install fpm

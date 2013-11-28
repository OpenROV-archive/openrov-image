#!/bin/bash
export DIR=${PWD#}
export IMAGE=$1
export STEP_01_IMAGE=$DIR/work/step_01/image.step_01.img
export STEP_02_IMAGE=$DIR/work/step_02/image.step_02.img

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

checkroot

if [ "$1" = "" ] && [ ! -f $STEP_01_IMAGE ]; then
	echo "Please pass the name of the Step 1 image file or make sure it exists in: $STEP_01_IMAGE"
	exit 1
fi

echo -----------------------------
echo Step 2: creating copy of image file:
echo "> $STEP_02_IMAGE"
echo -----------------------------

IMAGE_DIR_NAME=$( dirname $STEP_02_IMAGE )

if [ ! -d $IMAGE_DIR_NAME ] 
then
	mkdir -p "$IMAGE_DIR_NAME"
fi
cp $STEP_01_IMAGE $STEP_02_IMAGE
echo -----------------------------
echo done
echo -----------------------------
echo Preparing image
echo -----------------------------

# mounting
cd $DIR
mount_image $STEP_02_IMAGE

export ROOT=${PWD#}/root

chroot_mount

# copy qemu for chrooting
cp /usr/bin/qemu-arm-static $ROOT/usr/bin/

echo -----------------------------
echo Updating ubuntu packages
echo -----------------------------

cat > $ROOT/tmp/update.sh << __EOF__
#!/bin/bash

# update
sudo apt-get -y update
sudo apt-get -y upgrade
#dpkg-reconfigure openssh-server

echo Installing additional packages
sudo apt-get -y install \
	linux-firmware \
	devmem2 \
	python-software-properties \
	python-configobj \
	python-jinja2 \
	python-serial \
	gcc \
	g++ \
	make \
	libjpeg-dev \
	picocom \
	zip \
	unzip \
	vim \
	ethtool \
	arduino-core \
	avr-libc \
	avrdude \
	binutils-avr \
	bison \
	flex \
	autoconf \
	libftdi-dev \
	libusb-dev \
	samba \
	mercurial #needed for cloud9

#remove apache
dpkg -r apache2

/etc/init.d/samba stop

__EOF__
chmod +x $ROOT/tmp/update.sh

chroot $ROOT /tmp/update.sh

rm $ROOT/tmp/update.sh

chroot_umount
unmount_image
 
echo -----------------------------
echo Done step 2
echo -----------------------------

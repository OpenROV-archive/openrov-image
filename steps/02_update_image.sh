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
echo Updating packages
echo -----------------------------

cat > $ROOT/tmp/update.sh << __EOF__
#!/bin/bash

# update
sudo apt-get -y update
sudo apt-get -y upgrade
#dpkg-reconfigure openssh-server

echo Installing additional packages
sudo apt-get -y install \
	python-software-properties \
	python-configobj \
	python-jinja2 \
	python-serial \
	gcc \
	g++ \
	make \
	libjpeg8-dev \
	picocom \
	zip \
	unzip \
	vim \
	ethtool \
	avr-libc \
        arduino-core \
	automake \
	byacc \
	binutils-avr \
	bison \
	flex \
	autoconf \
	libftdi-dev \
	libusb-dev \
	samba \
        curl \
	mercurial #needed for cloud9

#remove apache
apt-get -y remove apache2

# Samba doesn't start on the chroot, we need to add an config section and reconfigure it, otherwise the openrov-samba-config packages failes to install
echo Fixing samba 
sed -i '/interfaces =/a interfaces = lo' /etc/samba/smb.conf
sed -i '0,/interfaces =/{//d;}' /etc/samba/smb.conf
dpkg --configure samba

/etc/init.d/samba stop
/etc/init.d/sshd stop

echo Updating fstab for improved mount options
sed -i 's/\/dev\/mmcblk0p2.*/\/dev\/mmcblk0p2  \/            ext4  data=writeback,commit=600,nodiratime,noatime,norelatime  0  1/' /etc/fstab

echo "FSCKFIX=no" >> /etc/default/rcS 

__EOF__
chmod +x $ROOT/tmp/update.sh

chroot $ROOT /tmp/update.sh

rm $ROOT/tmp/update.sh

chroot_umount

echo Setting the root fs mode to minimise impact of suddenly loosing power
#tune2fs -O ^has_journal $ROOT_media
tune2fs -o journal_data_writeback  $ROOT_media
#tune2fs -O ^has_journal -o journal_data_writeback  $ROOT_media
#tune2fs -O ^has_journal -o ^journal_data_writeback /dev/mapper/loop0p2

unmount_image
 
echo -----------------------------
echo Done step 2
echo -----------------------------

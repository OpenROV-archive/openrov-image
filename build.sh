#!/bin/bash

export IMAGE=$1
export NODEGIT=https://github.com/joyent/node.git
export NODEVERSION=v0.10.15
export MJPG_STREAMERGIT=https://github.com/codewithpassion/mjpg-streamer.git
export INOGIT=https://github.com/amperka/ino.git

export DIR=${PWD#}

. $DIR/lib/libmount.sh
. $DIR/lib/libtools.sh

checkroot

if [ "$1" = "" ]; then
	echo "Please pass the name of the elinux ubuntu image (from http://elinux.org/BeagleBoardUbuntu) as the first argument."
	exit 1
fi

if [ "$2" = "" ] || [ "$2" = "--bone" ]; then
	uboot=bone
	image_suffix=

elif [ "$2" = "--black" ]; then
	uboot=bone_dtb
	image_suffix=-black
else
	echo "Currently only --bone and --black are supported as targets!"
	exit 1
fi

IMAGE_FULLNAME=$(basename "$IMAGE")
IMAGE_NAME="${IMAGE_FULLNAME%%.*}"

# 
echo Extract the image: $IMAGE${IMAGE}
if which pv > /dev/null ; then
		echo Image ${IMAGE} 
			pv "${IMAGE}" | tar -xJf - 
		else
			echo "pv: not installed, using tar verbose to show progress"
			tar xvf "${IMAGE}"
		fi

cd $IMAGE_NAME

# fix the size of the image file
sed -i 's/\[1024\*800\]/\[1024*1500]/' setup_sdcard.sh

echo "Building image file!"
sleep 1
./setup_sdcard.sh --uboot $uboot --img || exit 1

# mounting
cd ..
mount_image $IMAGE_NAME/image.img

export ROOT=${PWD#}/root

chroot_mount

# copy qemu for chrooting
cp /usr/bin/qemu-arm-static $ROOT/usr/bin/

# build node
sh $DIR/lib/nodejs.sh $DIR/work $NODEGIT $NODEVERSION $ROOT/tmp/work/node/

# get mjpeg-streamer
cd $ROOT/tmp/work
git clone $MJPG_STREAMERGIT mjpg-streamer

# get ino
cd $ROOT/tmp/work
git clone https://github.com/amperka/ino.git ino
cd ino
wget http://peak.telecommunity.com/dist/ez_setup.py

# get dtc, we compile it in chroot
cd $ROOT/tmp/work
git clone git://git.kernel.org/pub/scm/linux/kernel/git/jdl/dtc.git
cd dtc
git checkout master -f
git pull || true
git checkout 65cc4d2748a2c2e6f27f1cf39e07a5dbabd80ebf -b 65cc4d2748a2c2e6f27f1cf39e07a5dbabd80ebf-build

# avrdude
cd $ROOT/tmp/work
git clone https://github.com/kcuzner/avrdude.git

cd $ROOT/opt
git clone https://github.com/OpenROV/openrov-software.git openrov
cd openrov
npm install --arch=arm
cd $ROOT

cp $DIR/lib/customizeroot.sh ./tmp/
chroot . /tmp/customizeroot.sh

cd $DIR 

# change boot script for uart
sed -i '/#optargs/a optargs=capemgr.enable_partno=BB-UART1' $DIR/boot/uEnv.txt

# change Start.html and autorun.inf file for OpenROV
sed -i 's/192.168.7.2/192.168.7.2:8080/' $DIR/boot/START.htm

sed -i 's/icon=Docs\\beagle.ico/icon=Docs\\openrov.ico/' $DIR/boot/autorun.inf
sed -i 's/label=BeagleBone Getting Started/label=OpenROV Cockpit/' $DIR/boot/autorun.inf
sed -i 's/action=Open BeagleBone Getting Started Guide/action=Open the OpenROV Cockpit/' $DIR/boot/autorun.inf

cp $DIR/lib/openrov.ico $DIR/boot/Docs/

cd $DIR
sync
sleep 1

chroot_umount

unmount_image

cp $DIR/$IMAGE_NAME/image.img $DIR/OpenROV${image_suffix}.img

echo Image file: OpenROV${image_suffix}.img
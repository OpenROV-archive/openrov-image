#!/bin/bash

export IMAGE=$1
export NODEGIT=git://github.com/joyent/node.git
export NODEVERSION=v0.10.17
export MJPG_STREAMERGIT=git://github.com/codewithpassion/mjpg-streamer.git
export INOGIT=https://github.com/amperka/ino.git
export OPENROV_GIT=git://github.com/OpenROV/openrov-software.git
export OPENROV_BRANCH=controlboard25

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

cd $IMAGE_NAME*

# fix the size of the image file
sed -i 's/\[1024\*800\]/\[1024*1500]/' setup_sdcard.sh

echo "Building image file!"
sleep 1
./setup_sdcard.sh --uboot $uboot --img || exit 1

# mounting
cd ..
mount_image $IMAGE_NAME*/image.img

export ROOT=${PWD#}/root

chroot_mount

# copy qemu for chrooting
cp /usr/bin/qemu-arm-static $ROOT/usr/bin/

mkdir $ROOT/tmp/work/
# build node
sh $DIR/lib/nodejs.sh $DIR/work $NODEGIT $NODEVERSION $ROOT/tmp/work/node/
#build node 0.8.22 for cloud9
#sh $DIR/lib/nodejs.sh $DIR/work $NODEGIT v0.8.22 $ROOT/tmp/work/node08/

# get mjpeg-streamer
cd $ROOT/tmp/work
git clone $MJPG_STREAMERGIT mjpg-streamer

# get ino
cd $ROOT/tmp/work
git clone $INOGIT
cd ino
wget http://peak.telecommunity.com/dist/ez_setup.py

# get dtc, we compile it in chroot
cd $ROOT/tmp/work
git clone git://git.kernel.org/pub/scm/linux/kernel/git/jdl/dtc.git
cd dtc
git checkout master -f
git pull || true
git checkout 65cc4d2748a2c2e6f27f1cf39e07a5dbabd80ebf -b 65cc4d2748a2c2e6f27f1cf39e07a5dbabd80ebf-build
git pull git://github.com/RobertCNelson/dtc.git dtc-fixup-65cc4d2

# avrdude
if [ ! -d $DIR/work/avrdude ] 
then
	cd $ROOT/tmp/work
	git clone https://github.com/kcuzner/avrdude.git
	cd avrdude/avrdude
	git apply $DIR/contrib/avrdude.patch
else
	cp -r $DIR/work/avrdude $ROOT/tmp/work
	touch $ROOT/tmp/work/avrdude/_BUILT
fi

#cloud9
#cd $ROOT/tmp/work
#wget https://github.com/ajaxorg/cloud9/archive/v2.0.93.zip
#unzip v2.0.93.zip
#mv cloud9-2.0.93

cd $ROOT/opt
git clone $OPENROV_GIT openrov
cd openrov
git checkout $OPENROV_BRANCH
npm install --arch=arm
cd $ROOT

cp $DIR/lib/customizeroot.sh ./tmp/
cp $DIR/contrib/Arduino-1.0.4-libraries.tgz ./tmp/
chroot . /tmp/customizeroot.sh

cd $DIR 

if [ ! -d $DIR/work/avrdude ] 
then
	cp -r $ROOT/tmp/work/avrdude $DIR/work/avrdude
fi

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

#cleanup
rm -rf $ROOT/tmp/*

chroot_umount

unmount_image

cp $DIR/$IMAGE_NAME*/image.img $DIR/OpenROV${image_suffix}.img

echo Image file: OpenROV${image_suffix}.img

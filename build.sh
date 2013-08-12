#!/bin/sh

export IMAGE=$1
export NODEGIT=https://github.com/joyent/node.git
export NODEVERSION=v0.10.15
export MJPG_STREAMERGIT=https://github.com/codewithpassion/mjpg-streamer.git
export INOGIT=https://github.com/amperka/ino.git

export DIR=${PWD#}


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root or with sudo" 1>&2
   exit 1
fi

if [ "$1" = "" ]; then
	echo "Please pass the name of the elinux ubuntu image (from http://elinux.org/BeagleBoardUbuntu) as the first argument."
	exit 1
fi
 
if [ "$2" = "" ] || [ "$2" = "--bone" ]; then
	uboot=bone

elif [ "$2" = "--black" ]; then
	uboot=bone_dbt

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
	media_loop=$(losetup -f || true)
	if [ ! "${media_loop}" ] ; then
		echo "losetup -f failed"
		echo "Unmount some via: [sudo losetup -a]"
		echo "-----------------------------"
		losetup -a
		echo "sudo kpartx -d /dev/loopX ; sudo losetup -d /dev/loopX"
		echo "-----------------------------"
		exit
	fi

	losetup ${media_loop} image.img
	kpartx -av ${media_loop}
	sleep 1
	sync
	test_loop=$(echo ${media_loop} | awk -F'/' '{print $3}')
	if [ -e /dev/mapper/${test_loop}p1 ] && [ -e /dev/mapper/${test_loop}p2 ] ; then
		media_prefix="/dev/mapper/${test_loop}p"
		ROOT_media=${media_prefix}2
	else
		ls -lh /dev/mapper/
		echo "Error: not sure what to do (new feature)."
		exit
	fi
cd ..
mkdir root
cd root
export ROOT=${PWD#}

mount $ROOT_media $ROOT

cd $ROOT

echo Mounting system directories from root: $ROOT
mount --bind /dev/ dev/
mount --bind /proc/ proc/
mount --bind /sys/ sys/
mount --bind /run/ run/
mount --bind /etc/resolv.conf etc/resolv.conf

# copy qemu for chrooting
cp /usr/bin/qemu-arm-static usr/bin/

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


cd $ROOT/opt
git clone https://github.com/OpenROV/openrov-software.git openrov
cd openrov
npm install --arch=arm
cd $ROOT

cp $DIR/lib/customizeroot.sh ./tmp/
chroot . /tmp/customizeroot.sh

echo Unmounting system directories
umount etc/resolv.conf
umount run
umount sys
umount proc
umount dev

cd $DIR 
umount $ROOT

kpartx -d ${media_loop}
losetup -d ${media_loop}

echo Image file: image.img
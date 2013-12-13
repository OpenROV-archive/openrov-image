#!/bin/sh

. $DIR/versions.sh

export DIR=${PWD#}

export MJPG_STREAMERGIT=git://github.com/codewithpassion/mjpg-streamer.git
export MJPG_STREAMER_PACKAGE_DIR=$DIR/work/step_03/mjpg-streamer

if [ ! "$1" = "" ];
then
	STEP_03_IMAGE=$1	
fi

if [ "$STEP_03_IMAGE" = "" ] || [ ! -f "$STEP_03_IMAGE" ];
then
	echo "Please pass the name the Step 3 image in the environment variable STEP_03_IMAGE"
	exit 1
fi

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

checkroot

mount_image $STEP_03_IMAGE

export ROOT=${PWD#}/root

chroot_mount

cd $ROOT/tmp/
if [ ! -d mjpg-streamer ];
then
	git clone $MJPG_STREAMERGIT mjpg-streamer
fi


cat > $ROOT/tmp/build_mjpeg_streamer.sh << __EOF__
#!/bin/sh

cd /tmp/mjpg-streamer/mjpg-streamer
mkdir -p /tmp/mjpg-streamer_install/usr/local/
mkdir -p /tmp/mjpg-streamer_install/usr/local/bin
mkdir -p /tmp/mjpg-streamer_install/usr/local/lib

make install DESTDIR=/tmp/mjpg-streamer_install/usr/local

__EOF__

chmod +x $ROOT/tmp/build_mjpeg_streamer.sh

chroot $ROOT /tmp/build_mjpeg_streamer.sh


cd $DIR

rm $ROOT/tmp/build_mjpeg_streamer.sh

if [ ! -d $MJPG_STREAMER_PACKAGE_DIR ]; then
	mkdir -p $MJPG_STREAMER_PACKAGE_DIR
fi

cp -r $ROOT/tmp/mjpg-streamer_install/usr $MJPG_STREAMER_PACKAGE_DIR

sleep 2
chroot_umount
unmount_image

cd $DIR/work/packages/
fpm -f -m info@openrov.com -s dir -t deb -a armhf -n openrov-mjpeg-streamer -v $MJPG_VERSION -C $MJPG_STREAMER_PACKAGE_DIR .

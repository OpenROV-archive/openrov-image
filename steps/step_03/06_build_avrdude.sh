#!/bin/bash
set -x
set -e
export DIR=${PWD#}

. $DIR/versions.sh

export AVRDUDEGIT=https://github.com/kcuzner/avrdude.git
export AVRDUDE_PACKAGE_DIR=$DIR/work/step_03/avrdude

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
chroot_mount

export ROOT=${PWD#}/root

cd $ROOT/tmp
git clone $AVRDUDEGIT
git reset -- hard $AVRDUDE_GITHASH

echo Current dir:
pwd
cd avrdude/avrdude
pwd
echo ###
#git apply $DIR/contrib/avrdude.patch

cat > $ROOT/tmp/build_avrdude.sh << __EOF__
#!/bin/bash

echo Building avrdude
cd /tmp/avrdude/avrdude
PATH=/usr/:$PATH
./bootstrap
./configure --prefix=/usr/ --localstatedir=/var/ --sysconfdir=/etc/ --enable-linuxgpio
make --jobs=8
make install DESTDIR=/tmp/avrdude_install

__EOF__

chmod +x $ROOT/tmp/build_avrdude.sh
chroot $ROOT /tmp/build_avrdude.sh

if [ ! -d $AVRDUDE_PACKAGE_DIR ];
then
	mkdir -p $AVRDUDE_PACKAGE_DIR
fi
cp -r $ROOT/tmp/avrdude_install/* $AVRDUDE_PACKAGE_DIR

cd $DIR
sync
sleep 2
chroot_umount
unmount_image


cd $DIR/work/packages/
fpm -f -m info@openrov.com -s dir -t deb -a armhf \
	-n openrov-avrdude \
	-v $AVRDUDE_VERSION \
	--after-install=$DIR/steps/step_03/openrov-avrdude-afterinstall.sh \
	--description "OpenROV avrdude package" \
	-C $AVRDUDE_PACKAGE_DIR .

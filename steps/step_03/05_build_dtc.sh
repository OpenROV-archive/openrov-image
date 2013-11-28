#!/bin/sh

export DIR=${PWD#}

export DTCGIT=git://git.kernel.org/pub/scm/linux/kernel/git/jdl/dtc.git
export DTC_PACKAGE_DIR=$DIR/work/step_03/dtc

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
git clone $DTCGIT

cd dtc
git checkout master -f
git pull || true
git checkout 65cc4d2748a2c2e6f27f1cf39e07a5dbabd80ebf -b 65cc4d2748a2c2e6f27f1cf39e07a5dbabd80ebf-build
git pull git://github.com/RobertCNelson/dtc.git dtc-fixup-65cc4d2

cat > $ROOT/tmp/build_dtc.sh << __EOF__
#!/bin/sh

echo Builing dtc
cd /tmp/dtc

make PREFIX=/usr/ CC=gcc CROSS_COMPILE= all --jobs=8
echo "Installing dtc into: /usr/bin/"
sudo make PREFIX=/usr/ install DESTDIR=/tmp/dtc_install

__EOF__

chmod +x $ROOT/tmp/build_dtc.sh
chroot $ROOT /tmp/build_dtc.sh

cp -r $ROOT/tmp/dtc_install/* $DTC_PACKAGE_DIR

cd $DIR
sync
sleep 2
chroot_umount
unmount_image


cd $DIR/work/packages/
fpm -f -m info@openrov.com -s dir -t deb -a armhf -n openrov-dtc -v 1.4-0 -C $DTC_PACKAGE_DIR .

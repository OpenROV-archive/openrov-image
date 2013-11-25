#!/bin/sh

export DIR=${PWD#}

export INOGIT=https://github.com/amperka/ino.git
export INO_PACKAGE_DIR=$DIR/work/step_03/ino

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
git clone $INOGIT

cd ino
wget http://peak.telecommunity.com/dist/ez_setup.py


cat > $ROOT/tmp/build_ino.sh << __EOF__
#!/bin/sh

echo Builing ino
cd /tmp/ino
python ez_setup.py
make install DESTDIR=/tmp/ino_install

__EOF__

chmod +x $ROOT/tmp/build_ino.sh
chroot $ROOT /tmp/build_ino.sh


if [ ! -d $INO_PACKAGE_DIR/usr ]; then
	mkdir -p $INO_PACKAGE_DIR/usr
fi
cp -r $ROOT/tmp/ino_install/usr $INO_PACKAGE_DIR

cd $DIR 

sync
sleep 2
chroot_umount
unmount_image


cd $DIR/work/packages/
fpm -f -m info@openrov.com -s dir -t deb -a armhf -n openrov-ino -v 0.3.6-0 -C $INO_PACKAGE_DIR .

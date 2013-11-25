#!/bin/sh

export DIR=${PWD#}

export OPENROV_GIT=git://github.com/OpenROV/openrov-software.git
export OPENROV_BRANCH=controlboard25
export OPENROV_PACKAGE_DIR=$DIR/work/step_03/openrov

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
cp $DIR/contrib/Arduino-1.0.4-libraries.tgz ./tmp/

mount_image $STEP_03_IMAGE
chroot_mount

export ROOT=${PWD#}/root

cd $ROOT/opt
git clone $OPENROV_GIT openrov
cd openrov
git checkout $OPENROV_BRANCH
npm install --arch=arm

cat > $ROOT/tmp/build_cockpit.sh << __EOF__
#!/bin/sh

cd /opt/openrov
/opt/node/bin/npm rebuild

__EOF__

chmod +x $ROOT/tmp/build_cockpit.sh
chroot $ROOT /tmp/build_cockpit.sh

mkdir -p $OPENROV_PACKAGE_DIR/opt/openrov

cp -r $ROOT/opt/openrov $OPENROV_PACKAGE_DIR/opt/openrov

sync
sleep 2
chroot_umount
unmount_image

cd $DIR/work/packages/
fpm -s dir -t deb -a armhf -n openrov-cockpit -v 2.5.0-0 -C $OPENROV_PACKAGE_DIR .

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

mount_image $STEP_03_IMAGE
chroot_mount

export ROOT=${PWD#}/root

cd $ROOT/opt
git clone $OPENROV_GIT openrov
cd openrov
git pull origin
g#t checkout $OPENROV_BRANCH
npm install --arch=armhf

cat > $ROOT/tmp/build_cockpit.sh << __EOF__
#!/bin/sh

#install nodejs
dpkg -i /tmp/openrov-nodejs*.deb

cd /opt/openrov
#opt/node/bin/npm rebuild

__EOF__

cp $DIR/work/packages/openrov-nodejs* $ROOT/tmp/

chmod +x $ROOT/tmp/build_cockpit.sh
chroot $ROOT /tmp/build_cockpit.sh

mkdir -p $OPENROV_PACKAGE_DIR/opt/openrov

cp -r $ROOT/opt/openrov $OPENROV_PACKAGE_DIR/opt

cd $DIR

sync
sleep 2
chroot_umount
unmount_image


cd $DIR/work/packages/
fpm -f -m info@openrov.com -s dir -t deb -a armhf \
	-n openrov-cockpit \
	-v 2.5.0-0 \
	-d 'openrov-nodejs' \
	--after-install=$DIR/steps/step_03/openrov-cockpit-afterinstall.sh \
	--before-remove=$DIR/steps/step_03/openrov-cockpit-beforeremove.sh \
	-C $OPENROV_PACKAGE_DIR .

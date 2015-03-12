#!/bin/bash
set -x
set -e
export DIR=${PWD#}

. $DIR/versions.sh

export PROXYGIT=https://github.com/OpenROV/openrov-proxy.git
export PROXY_PACKAGE_DIR=$DIR/work/step_03/proxy

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
git clone $PROXYGIT proxy

cd proxy

cat > $ROOT/tmp/build_proxy.sh << __EOF__
#!/bin/bash
set -x
set -e
echo Builing proxy
cd /tmp/proxy/proxy-via-browser/

npm install

__EOF__

chmod +x $ROOT/tmp/build_proxy.sh
chroot $ROOT /tmp/build_proxy.sh


if [ ! -d $PROXY_PACKAGE_DIR/opt/openrov/proxy ]; then
	mkdir -p $PROXY_PACKAGE_DIR/opt/openrov/proxy
fi
cp -r $ROOT/tmp/proxy/proxy-via-browser/* $PROXY_PACKAGE_DIR/opt/openrov/proxy

cd $DIR

sync
sleep 2
chroot_umount
unmount_image


cd $DIR/work/packages/
fpm -f -m info@openrov.com -s dir -t deb -a armhf \
	-n openrov-proxy \
	-v ${PROXY_VERSION} \
        --after-install=$DIR/steps/step_03/openrov-proxy-afterinstall.sh \
        --before-remove=$DIR/steps/step_03/openrov-proxy-beforeremove.sh \
	--description "OpenROV proxy package" \
	-C $PROXY_PACKAGE_DIR .

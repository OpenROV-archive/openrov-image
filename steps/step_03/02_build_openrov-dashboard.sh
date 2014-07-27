#!/bin/sh
export DIR=${PWD#}

. $DIR/versions.sh

if [ "$OPENROV_GIT" = "" ]; then
	export OPENROV_GIT=git://github.com/OpenROV/openrov-dashboard.git
fi
if [ "$OPENROV_BRANCH" = "" ]; then
	export OPENROV_BRANCH=master
fi
export OPENROV_PACKAGE_DIR=$DIR/work/step_03/dashboard

if [ ! "$1" = "" ];
then
	STEP_03_IMAGE=$1
fi

if [ "$2" = "--local-dashboard-source" ];
then
	export LOCAL_DASHBOARD_SOURCE=$3
fi

if [ "$STEP_03_IMAGE" = "" ] || [ ! -f "$STEP_03_IMAGE" ];
then
	echo "Please pass the name the Step 3 image in the environment variable STEP_03_IMAGE"
	exit 1
fi

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

function onerror() {
  cd $DIR
  sleep 2
  chroot_umount
  sleep 2
  chroot_umount
  unmount_image
  sleep 2
  unmount_image
  echo There was a problem with the script!
  exit 1
}

checkroot

mount_image $STEP_03_IMAGE
chroot_mount

export ROOT=${PWD#}/root


cd $ROOT/opt
rm -rf openrov
mkdir -p openrov
cd openrov
rm dashboard -rf
if [ "$LOCAL_COCKPIT_SOURCE" = "" ];
then
	git clone $OPENROV_GIT dashboard
	ls .
	cd dashboard
	ls .
	git pull origin
	git checkout $OPENROV_BRANCH
else
	cp -r "$LOCAL_COCKPIT_SOURCE" dashboard
	cd openrov/dashboard
fi
npm install --arch=armhf || onerror
git clean -d -x -f -e node_modules

cat > $ROOT/tmp/build_dashboard.sh << __EOF__
#!/bin/sh

#install nodejs
dpkg -i /tmp/openrov-nodejs*.deb

cd /opt/openrov/dashboard
ls .
/opt/node/bin/npm rebuild

__EOF__

cp $DIR/work/packages/openrov-nodejs* $ROOT/tmp/

chmod +x $ROOT/tmp/build_dashboard.sh
chroot $ROOT /tmp/build_dashboard.sh

rm -rf $OPENROV_PACKAGE_DIR/opt/openrov/dashboard

mkdir -p $OPENROV_PACKAGE_DIR/opt/openrov/dashboard
echo 4
pwd
echo $ROOT/opt/openrov/dashboard/
echo $OPENROV_PACKAGE_DIR/opt/openrov/dashboard
ls $OPENROV_PACKAGE_DIR/opt/openrov/dashboard

cp -rv $ROOT/opt/openrov/dashboard/ $OPENROV_PACKAGE_DIR/opt/openrov/dashboard

cd $DIR
echo 5
pwd
sync
sleep 2
chroot_umount
sleep 2
chroot_umount
unmount_image
sleep 2
unmount_image


cd $DIR/work/packages/
fpm -f -m info@openrov.com -s dir -t deb -a armhf \
	-n openrov-dashboard \
	-v $DASHBOARD_VERSION \
	-d 'openrov-nodejs' \
	--before-install=$DIR/steps/step_03/openrov-dashboard-beforeinstall.sh \
	--after-install=$DIR/steps/step_03/openrov-dashboard-afterinstall.sh \
	--before-remove=$DIR/steps/step_03/openrov-dashboard-beforeremove.sh \
	--description "OpenROV Dashboard" \
	-C $OPENROV_PACKAGE_DIR/opt/openrov/dashboard .=/opt/openrov

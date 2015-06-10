#!/bin/bash
set -x
set -e
export DIR=${PWD#}
export IMAGE=$1
export STEP_02_IMAGE=$DIR/work/step_02/image.step_02.img
export STEP_04_IMAGE=$DIR/work/step_04/image.step_04.img
export OUTPUT_IMAGE=$DIR/output/OpenROV.img
export USE_REPO=${USE_REPO:-''} # use the repository at build.openrov.com/debian as package source
export REPO=deb-repo.openrov.com

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh
. $DIR/versions.sh

checkroot

if [ "$1" = "--reuse-step4" ] && [ ! -f $STEP_04_IMAGE ]; then
	echo "You specified --reuse-step4 but the Step 4 image does not exists in: $STEP_04_IMAGE"
	exit 1

elif [ "$1" = "" ] && [ ! -f $STEP_02_IMAGE ]; then
	echo "Please pass the name of the Step 2 image file or make sure it exists in: $STEP_02_IMAGE"
	exit 1
fi


if [ ! "$1" = "--reuse-step4" ]; then
	echo -----------------------------
	echo Step 4: creating copy of image file:
	echo "> $STEP_04_IMAGE"
	echo -----------------------------

	IMAGE_DIR_NAME=$( dirname $STEP_04_IMAGE )

	if [ ! -d $IMAGE_DIR_NAME ]
	then
		mkdir -p "$IMAGE_DIR_NAME"
	fi
	cp $STEP_02_IMAGE $STEP_04_IMAGE
	echo -----------------------------
	echo done
	echo -----------------------------
else

	echo -----------------------------
	echo using $STEP_04_IMAGE
	echo -----------------------------
fi
echo Preparing image
echo -----------------------------

# mounting
cd $DIR
mount_image $STEP_04_IMAGE

export ROOT=${PWD#}/root

chroot_mount

# copy the qemu files for chroot to arm
cp /usr/bin/qemu-arm-static $ROOT/usr/bin/qemu-arm-static

if [ "$USE_REPO" = "" ]; then

	echo -----------------------------
	echo Staging packages for install
	echo -----------------------------
	#trying to mount bind instaed of copy to save space
	if [ ! -d $ROOT/tmp/packages ]
	then
		mkdir $ROOT/tmp/packages
		mount --bind $DIR/work/packages $ROOT/tmp/packages
	fi
fi

echo -----------------------------
echo Customizing image
echo -----------------------------

cat > $ROOT/tmp/update.sh << __EOF_UPDATE__
#!/bin/bash
set -x
set -e
export REPO=$REPO
echo ------------------------------
#echo installing bower
#npm install -ddd -g bower
dpkg --list | grep 'apache2' && apt-get remove -y apache2

#echo "Add Node JS from source repo"
wget -qO- https://deb.nodesource.com/setup | bash -
#apt-get update
apt-get install -y nodejs curl

#may need to patch old NPM here.

#echo "Upgrade npm"
wget -qO- https://www.npmjs.org/install.sh | sh

#	apt-get install -y npm
/usr/bin/npm --version

echo -----------------------------
echo Adding the apt-get configuration
echo -----------------------------
apt-get clean

#add code to make sure the wheezy backports are available
sed -i 's|#deb http://ftp.debian.org/debian jessie-backports|deb http://ftp.debian.org/debian jessie-backports|g'  /etc/apt/sources.list
sed -i 's|#deb http://ftp.debian.org/debian wheezy-backports|deb http://ftp.debian.org/debian wheezy-backports|g'  /etc/apt/sources.list

if [ $BRANCH == "master" ]; then
	#statements
#cat > /etc/apt/sources.list.d/openrov-stable.list << __EOF__
#deb http://$REPO stable debian
#deb [arch=all] http://$REPO stable debian
#__EOF__
cat > /etc/apt/sources.list.d/openrov-master.list << __EOF__
deb http://$REPO master debian
#deb [arch=all] http://$REPO master debian
__EOF__
#cat > /etc/apt/sources.list.d/openrov-pre-release.list << __EOF__
#deb http://$REPO pre-release debian
#deb [arch=all] http://$REPO pre-release debian
#__EOF__

else
	#statements
cat > /etc/apt/sources.list.d/openrov-stable.list << __EOF__
deb http://$REPO stable debian
#deb [arch=all] http://$REPO stable debian
__EOF__
#cat > /etc/apt/sources.list.d/openrov-master.list << __EOF__
#deb http://$REPO master debian
#deb [arch=all] http://$REPO master debian
#__EOF__
cat > /etc/apt/sources.list.d/openrov-pre-release.list << __EOF__
deb http://$REPO pre-release debian
#deb [arch=all] http://$REPO pre-release debian
__EOF__
fi

cat > /etc/apt/preferences.d/openrov-master-300 << __EOF__
Package: *
Pin: release n=master, origin deb-repo.openrov.com
Pin-Priority: 300
__EOF__
cat > /etc/apt/preferences.d/openrov-pre-release-400 << __EOF__
Package: *
Pin: release n=pre-release, origin deb-repo.openrov.com
Pin-Priority: 400
__EOF__
cat > /etc/apt/preferences.d/openrov-stable-release-1001 << __EOF__
Package: *
Pin: release n=stable, origin deb-repo.openrov.com
Pin-Priority: 1001
__EOF__


echo Adding gpg key for build.openrov.com
wget -O - -q http://${REPO}/build.openrov.com.gpg.key | apt-key add -

echo -----------------------------
echo Installing packages
echo -----------------------------

rm -rf /tmp/packages

if [ "$USE_REPO" != "" ]; then
	apt-get clean
	rm -rf /var/lib/apt/lists/*
	apt-get update
	apt-get install -y --force-yes -o Dpkg::Options::="--force-overwrite" \
		-t $BRANCH openrov-rov-suite
  if [ "$MAKE_FLASH" == "true" ]; then
		apt-get install -y --force-yes -o Dpkg::Options::="--force-overwrite" \
			-t $BRANCH openrov-emmc-copy
  fi
fi

apt-get clean
__EOF_UPDATE__

chmod +x $ROOT/tmp/update.sh

chroot $ROOT /tmp/update.sh

rm $ROOT/tmp/* -r

echo Setting up auto resize on first boot
touch $ROOT/var/.RESIZE_ROOT_PARTITION

echo ------------------------------
echo Fixing arduino

#fix arduino version
echo 1.0.5 > $ROOT/usr/share/arduino/lib/version.txt
#fix arduino library source
cd $ROOT/usr/share/arduino/
rm -r libraries
tar zxf $DIR/contrib/Arduino-1.0.4-libraries.tgz
cd $DIR

echo ------------------------------
echo Customizing boot partition

#This no longer works on debian
# change boot script for uart
#sed -i '3ioptargs=capemgr.enable_partno=BB-UART1' $DIR/boot/uEnv.txt

#mkdir $DIR/boot/Docs
#cp $DIR/contrib/openrov.ico $DIR/boot/Docs/
#cp $DIR/contrib/boot/* $DIR/boot/


echo ------------------------------
echo done
echo ------------------------------

chroot_umount
unmount_image

OUTPUT_DIR_NAME=$( dirname $OUTPUT_IMAGE )
if [ ! -d $OUTPUT_DIR_NAME ];  then
	mkdir -p $OUTPUT_DIR_NAME
fi

echo -----------------------------
echo Moving image
echo "> $OUTPUT_IMAGE"
mv $STEP_04_IMAGE $OUTPUT_IMAGE

echo -----------------------------
echo Done step 4
echo "Output can be found in: $OUTPUT_DIR_NAME"
echo -----------------------------

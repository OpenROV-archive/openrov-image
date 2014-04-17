#!/bin/bash
export DIR=${PWD#}
export IMAGE=$1
export STEP_04_IMAGE=$DIR/work/step_04/image.step_04.img
export OUTPUT_IMAGE=$DIR/output/OpenROV-flash.img

. $DIR/lib/libtools.sh
. $DIR/lib/libmount.sh

checkroot

if [ "$1" = "" ] && [ ! -f $STEP_04_IMAGE ]; then
	echo "Please pass the name of the Step 4 image file or make sure it exists in: $STEP_04_IMAGE"
	exit 1
fi

echo -----------------------------
echo Step 5: creating eMMC flashable image:
echo "> $OUTPUT_IMAGE"
echo -----------------------------

IMAGE_DIR_NAME=$( dirname $STEP_04_IMAGE )

if [ ! -d $IMAGE_DIR_NAME ] 
then
	mkdir -p "$IMAGE_DIR_NAME"
fi
cp $STEP_04_IMAGE $OUTPUT_IMAGE
echo -----------------------------
echo done
echo -----------------------------
# mounting
cd $DIR
mount_image $OUTPUT_IMAGE

export ROOT=${PWD#}/root

chroot_mount

cp -r $DIR/work/packages $ROOT/tmp/

echo -----------------------------
echo Creating eMMC flashable image
echo -----------------------------

cat > $ROOT/tmp/update.sh << __EOF_UPDATE__
#!/bin/bash

echo Installing eMCC flasher scripts
echo -----------------------------
dpkg -i --force-overwrite /tmp/packages/openrov-emmc-copy*.deb


__EOF_UPDATE__
chmod +x $ROOT/tmp/update.sh

chroot $ROOT /tmp/update.sh

rm -rf $ROOT/tmp/packages
rm $ROOT/tmp/update.sh

echo Removing auto resize, this is not needed for the eMMC flashed image
rm $ROOT/var/.RESIZE_ROOT_PARTITION


chroot_umount
unmount_image

echo -----------------------------
echo Done step 6
echo "Output can be found in: $OUTPUT_IMAGE"
echo -----------------------------

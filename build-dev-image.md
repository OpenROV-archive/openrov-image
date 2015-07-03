
#creating a disk image
```
wget  https://rcn-ee.com/rootfs/2015-05-08/microsd/bone-debian-8.0-console-armhf-2015-05-08-2gb.img.xz

unxz bone-debian-8.0-console-armhf-2015-05-08-2gb.img.xz

--- copy to the sd card ---
--- boot and login --- debian@arm.local

sudo bash
cat > /etc/apt/sources.list.d/openrov-master.list << __EOF__
deb http://deb-repo.openrov.com master debian
#deb [arch=all] http://$REPO master debian
__EOF__
wget -O - -q http://deb-repo.openrov.com/build.openrov.com.gpg.key | apt-key add -
apt-get clean
rm -rf /var/lib/apt/lists/*
apt-get update
apt-get install -y --force-yes -o Dpkg::Options::="--force-overwrite" -t master openrov-rov-suite
```

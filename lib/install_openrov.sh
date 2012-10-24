#/bin/sh
echo currently in:
echo `pwd`
DIR="`dirname \"$0\"`"

if [ ! -d /opt/openrov ]; then
	mkdir -p /opt/openrov
fi
cd $DIR
cp -r *.tgz /opt/openrov/
cd /opt/openrov/
tar zxf OpenROV*.tgz
cp -r package/* .
rm OpenROV*.tgz
rm -rf package

/opt/node/bin/npm rebuild

echo "rov ALL=NOPASSWD: /opt/openrov/linux/" >> /etc/sudoers

ln -s /opt/openrov/linux/openrov.service /etc/init.d/openrov
chmod +x /opt/openrov/linux/openrov.service

if [ -f '/etc/init.d/openrov' ]; then
	update-rc.d openrov defaults
fi  


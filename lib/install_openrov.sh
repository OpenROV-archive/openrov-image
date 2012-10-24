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
/opt/node/bin/npm install OpenROV.*.tgz
cp -r node_modules/OpenROV-Cockpit/*.* .
rm -rf node_modules/OpenROV-Cockpit

echo "rov ALL=NOPASSWD: /opt/openrov/linux/" >> /etc/sudoers

ln -s /opt/openrov/linux/openrov.service /etc/init.d/openrov
chmod +x /opt/openrov/linux/openrov.service

if [ -f '/etc/init.d/openrov' ]; then
	update-rc.d openrov defaults
fi  


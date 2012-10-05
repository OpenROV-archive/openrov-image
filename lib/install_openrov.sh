#/bin/sh
echo currently in:
echo `pwd`
DIR="`dirname \"$0\"`"

if [ ! -d /opt/openrov ]; then
	mkdir -p /opt/openrov
fi
cp -r /tmp/additions/openrov/openrov /opt/

echo "ls /opt:"
echo `ls /opt`

echo "rov ALL=NOPASSWD: /opt/openrov/linux/*.sh" >> /etc/sudoers

ln -s /opt/openrov/linux/openrov.service /etc/init.d/openrov

if [ -f '/etc/init.d/openrov' ]; then
	update-rc.d openrov defaults
fi  


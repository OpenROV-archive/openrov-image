#/bin/sh

DIR="`dirname \"$0\"`"

if [ ! -d /opt/node ]; then
	mkdir -p /opt/node
fi
cp -r $DIR/* /opt/node
rm /opt/node/install.sh

cd /home/rov/

git clone git://github.com/creationix/nvm.git .nvm
echo ". ~/.nvm/nvm.sh" >> .bashrc
echo "export LD_LIBRARY_PATH=/usr/local/lib" >> .bashrc
echo "export PATH=$PATH:/opt/node/bin" >> .bashrc

#right now, the cross compiler setus the wrong dinamic linker. We 'fix' this here:
ln -s /lib/arm-linux-gnueabihf/ld-2.15.so /lib/ld-linux.so.3


#/bin/sh
echo currently in:
echo `pwd`
DIR="`dirname \"$0\"`"

cd /tmp/additions/ino/ino 

echo Installing ino 
wget http://peak.telecommunity.com/dist/ez_setup.py
python ez_setup.py
make install


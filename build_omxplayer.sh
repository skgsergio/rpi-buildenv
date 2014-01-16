#!/bin/bash

if [ -z "$1" ]; then
  echo "Please provide a GitHub clone URL as argument"
  exit 1
fi

rm -rf omxplayer/
git clone $1 omxplayer
cp Makefile.include omxplayer/

cd omxplayer

make ffmpeg
make
make dist
FORK=`git remote -v | sed -e 's/.*github\.com\/\([^/]*\).*/\1/'`
VERSION=0.3.4~git~$FORK~`date +%Y%m%d`~`git describe --always --tag`

cd ..

mkdir -p package/omxplayer/DEBIAN
cp debian/{postrm,preinst,prerm} package/omxplayer/DEBIAN/
sed -e "s/##VERSION##/$VERSION/" debian/control.tmpl > package/omxplayer/DEBIAN/control
cp -aR omxplayer/omxplayer-dist/* package/omxplayer/
dpkg-deb --build package/omxplayer .
mv omxplayer.deb package/


#!/bin/bash
#
# Script for building latest omxplayer.
#
# Author:
#     Sergio Conde <skgsergio@gmail.com>
#     https://github.com/skgsergio/rpi-buildenv
#

. aux.inc.sh

run_chroot /root/omxplayer-build/build.sh

cp $rootfs_dir/root/omxplayer-build/*.deb .
rm $rootfs_dir/root/omxplayer-build/*.deb

ls -l *.deb
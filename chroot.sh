#!/bin/bash
#
# Script for chrooting into the rootfs.
#
# Author:
#     Sergio Conde <skgsergio@gmail.com>
#     https://github.com/skgsergio/rpi-buildenv
#


mount -t proc proc $rootfs/proc
mount -t sysfs sysfs $rootfs/sys
mount -o bind /dev $rootfs/dev

LC_ALL=C chroot $rootfs /bin/bash

umount $rootfs/dev
umount $rootfs/sys
umount $rootfs/proc

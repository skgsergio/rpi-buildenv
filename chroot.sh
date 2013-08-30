#!/bin/bash
#
# Script for chrooting into the rootfs.
#
# Author:
#     Sergio Conde <skgsergio@gmail.com>
#     https://github.com/skgsergio/rpi-buildenv
#

. aux.inc.sh

$cmd_sudo mount -t proc proc $rootfs_dir/proc
$cmd_sudo mount -t sysfs sysfs $rootfs_dir/sys
$cmd_sudo mount -o bind /dev $rootfs_dir/dev

run_chroot /bin/bash

$cmd_sudo umount $rootfs_dir/dev
$cmd_sudo umount $rootfs_dir/sys
$cmd_sudo umount $rootfs_dir/proc

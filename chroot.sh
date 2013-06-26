#!/bin/bash
#
# Script for chrooting into the rootfs.
#
# Author:
#     Sergio Conde <skgsergio@gmail.com>
#     https://github.com/skgsergio/rpi-buildenv
#

print_msg() {
    echo -e "\n[***] $@" 1>&2
}

# Check for root
if [[ $(whoami) == "root" ]]; then
    export cmd_sudo=""
else
    print_msg "This script needs to be run as root. It will automatically use 'sudo' so you will be asked for your password."
    print_msg "If you prefer you can directly run this script as root."

    echo
    read -sn 1 -p "Press any key to continue or Ctrl-C to quit."
    echo

    export cmd_sudo=$(which sudo)
    if [[ $? != 0 ]]; then
        raise_error "You don't have sudo installed. Please install sudo or run this script as root."
    fi

    echo
fi

$cmd_sudo mount -t proc proc $rootfs/proc
$cmd_sudo mount -t sysfs sysfs $rootfs/sys
$cmd_sudo mount -o bind /dev $rootfs/dev

LC_ALL=C $cmd_sudo chroot $rootfs /bin/bash

$cmd_sudo umount $rootfs/dev
$cmd_sudo umount $rootfs/sys
$cmd_sudo umount $rootfs/proc

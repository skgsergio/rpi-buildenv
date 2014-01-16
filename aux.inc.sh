#!/bin/bash
#
# Auxiliar functions and rootchek.
#
# Author:
#     Sergio Conde <skgsergio@gmail.com>
#     https://github.com/skgsergio/rpi-buildenv
#


## Auxiliar functions

raise_error() {
    echo -e "\n[!!!] $@" 1>&2
    exit 1
}

print_msg() {
    echo -e "\n[***] $@" 1>&2
}

run_chroot() {
    $cmd_sudo mount -t proc proc $rootfs_dir/proc
    $cmd_sudo mount -t sysfs sysfs $rootfs_dir/sys
    $cmd_sudo mount -o bind /dev $rootfs_dir/dev
    $cmd_sudo mount -o bind /dev/pts $rootfs_dir/dev/pts
    LC_ALL=C $cmd_sudo chroot $rootfs_dir $@
    sleep 1s
    $cmd_sudo umount $rootfs_dir/dev/pts
    $cmd_sudo umount $rootfs_dir/dev
    $cmd_sudo umount $rootfs_dir/sys
    $cmd_sudo umount $rootfs_dir/proc
}

## Check for root

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

export rootfs_dir="rootfs"

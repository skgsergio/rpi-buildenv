#!/bin/bash
#
# Script for setup a build environment for Raspberry Pi.
#
# Author:
#     Sergio Conde <skgsergio@gmail.com>
#     https://github.com/skgsergio/rpi-buildenv
#

RASPBIAN_MIRROR="http://archive.raspbian.org/raspbian/"
#RASPBIAN_MIRROR="http://raspbian.sconde.net/raspbian/"

## Auxiliar functions

raise_error() {
    echo -e "\n[!!!] $@" 1>&2
    exit 1
}

print_msg() {
    echo -e "\n[***] $@" 1>&2
}

chk_dep() {
    if [[ $($cmd_sudo which $1) == "" ]]; then
        echo "[ERR] $1 not found."

        if [[ $2 != "-" ]]; then
            echo -e "\nIf you are using Debian, Ubuntu, Mint or any other apt/deb based distribution you can install it using: apt-get install $2"
        fi

        exit 1
    else
        echo "[ OK] $1 found."
    fi
}

run_chroot() {
    mount -t proc proc $rootfs_dir/proc
    mount -t sysfs sysfs $rootfs_dir/sys
    mount -o bind /dev $rootfs_dir/dev
    LC_ALL=C chroot $rootfs_dir $@
    sleep 1s
    umount $rootfs_dir/dev
    umount $rootfs_dir/sys
    umount $rootfs_dir/proc
}

## BEGIN SCRIPT

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

# Start doing things. From here less comments, I think that the print_msg are enough.
export rootfs_dir="rootfs"

print_msg "Checking for dependencies...\n"

chk_dep debootstrap debootstrap
chk_dep qemu-debootstrap qemu-user-static
chk_dep chroot coreutils

print_msg "Downloading RaspberryPi tools...\n"

git submodule update --init

print_msg "Downloading Raspbian rootfs...\n"

$cmd_sudo qemu-debootstrap --no-check-gpg --include=ca-certificates,git-core,binutils --arch armhf wheezy $rootfs_dir $RASPBIAN_MIRROR

print_msg "Configuring rootfs...\n"

cat <<EOF | $cmd_sudo tee -a $rootfs_dir/usr/sbin/policy-rc.d > /dev/null
#!/bin/sh
echo "rc.d operations disabled for chroot"
exit 101
EOF

chmod 0755 $rootfs_dir/usr/sbin/policy-rc.d

print_msg "Importing Raspbian's GPG key...\n"

echo "deb $RASPBIAN_MIRROR wheezy main contrib non-free" | $cmd_sudo tee -a $rootfs_dir/etc/apt/sources.list > /dev/null

$cmd_sudo wget http://raspbian.sconde.net/raspbian.public.key -O $rootfs_dir/root/raspbian.key

run_chroot apt-key add /root/raspbian.key
run_chroot apt-get update

$cmd_sudo rm $rootfs_dir/root/raspbian.key

print_msg "Installing rpi-update into the rootfs and running it to fetch firmware and libraries...\n"

$cmd_sudo wget https://raw.github.com/Hexxeh/rpi-update/master/rpi-update -O $rootfs_dir/usr/bin/rpi-update
$cmd_sudo chmod +x $rootfs_dir/usr/bin/rpi-update
$cmd_sudo mkdir $rootfs_dir/lib/modules

run_chroot rpi-update

print_msg "Finished!"

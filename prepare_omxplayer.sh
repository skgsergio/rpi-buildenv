#!/bin/bash
#
# Script for installing omxplayer dependencies into the rootfs.
#
# Author:
#     Sergio Conde <skgsergio@gmail.com>
#     https://github.com/skgsergio/rpi-buildenv
#

. aux.inc.sh

print_msg "Updating apt cache...\n"

run_chroot apt-get update

print_msg "Installing build tools...\n"

run_chroot apt-get -y install build-essential gcc-4.7 g++-4.7 pkg-config ccache

print_msg "Installing build deps...\n"

run_chroot apt-get -y install libpcre3-dev libfreetype6-dev libboost-all-dev libglew-dev libdbus-1-dev libssl-dev libsmbclient-dev libssh-dev libasound2-dev

print_msg "Making GCC/G++ 4.7 default."

run_chroot update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7
run_chroot update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6

print_msg "Copying build files...\n"

$cmd_sudo cp -r omxplayer-build $rootfs_dir/root/omxplayer-build
$cmd_sudo chmod o+rx $rootfs_dir/root $rootfs_dir/root/omxplayer-build

print_msg "Finished!"

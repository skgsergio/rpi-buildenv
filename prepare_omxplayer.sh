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

run_chroot apt-get -y install build-essential gcc-4.7 g++-4.7 pkg-config

print_msg "Installing libpcre3-dev, libfreetype6-dev, libboost-all-dev, libglew-dev, libdbus-1-dev and libssl-dev...\n"

run_chroot apt-get -y install libpcre3-dev libfreetype6-dev libboost-all-dev libglew-dev libdbus-1-dev libssl-dev

print_msg "Copying build files...\n"

$cmd_sudo cp -r omxplayer-build $rootfs_dir/root/omxplayer-build
$cmd_sudo chmod o+rx $rootfs_dir/root $rootfs_dir/root/omxplayer-build

print_msg "Finished!"

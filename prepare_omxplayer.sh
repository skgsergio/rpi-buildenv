#!/bin/bash
#
# Script for installing omxplayer dependencies into the rootfs.
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
    LC_ALL=C $cmd_sudo chroot $rootfs_dir $@
    sleep 1s
    $cmd_sudo umount $rootfs_dir/dev
    $cmd_sudo umount $rootfs_dir/sys
    $cmd_sudo umount $rootfs_dir/proc
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

print_msg "Updating apt cache...\n"

run_chroot apt-get update

print_msg "Installing libpcre3-dev, libfreetype6-dev and libboost-all-dev...\n"

run_chroot apt-get -y install libpcre3-dev libfreetype6-dev libboost-all-dev

print_msg "Generating Makefile.include...\n"

cat <<EOF > Makefile.include
FLOAT = hard

HOST := arm-linux-gnueabihf
SYSROOT := $(pwd)/rootfs
TOOLCHAIN := $(pwd)/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/

CFLAGS := -isystem\$(PREFIX)/include
CXXFLAGS := \$(CFLAGS)
CPPFLAGS := \$(CFLAGS)
LDFLAGS := -L\$(SYSROOT)/lib

LD := \$(TOOLCHAIN)/bin/\$(HOST)-ld --sysroot=\$(SYSROOT)
CC := \$(TOOLCHAIN)/bin/\$(HOST)-gcc --sysroot=\$(SYSROOT)
CXX := \$(TOOLCHAIN)/bin/\$(HOST)-g++ --sysroot=\$(SYSROOT)
OBJDUMP := \$(TOOLCHAIN)/bin/\$(HOST)-objdump
RANLIB := \$(TOOLCHAIN)/bin/\$(HOST)-ranlib
STRIP := \$(TOOLCHAIN)/bin/\$(HOST)-strip
AR := \$(TOOLCHAIN)/bin/\$(HOST)-ar

CXXCP := \$(CXX) -E

PATH := \$(PREFIX)/bin:\$(TOOLCHAIN)/bin:\$(PATH)

CFLAGS += -pipe -mfloat-abi=\$(FLOAT) -mcpu=arm1176jzf-s -fomit-frame-pointer -mabi=aapcs-linux -mtune=arm1176jzf-s -mfpu=vfp -Wno-psabi -mno-apcs-stack-check -O3 -mstructure-size-boundary=32 -mno-sched-prolog
LDFLAGS += -L\$(SYSROOT)/lib -L\$(SYSROOT)/usr/lib -L\$(SYSROOT)/opt/vc/lib/
INCLUDES += -isystem\$(SYSROOT)/usr/include -isystem\$(SYSROOT)/opt/vc/include -isystem\$(SYSROOT)/usr/include -isystem\$(SYSROOT)/opt/vc/include/interface/vcos/pthreads -isystem\$(SYSROOT)/opt/vc/include/interface/vmcs_host/linux -isystem\$(SYSROOT)/usr/include/freetype2
EOF

print_msg "Finished!"

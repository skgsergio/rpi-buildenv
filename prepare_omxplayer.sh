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

print_msg "Installing libpcre3-dev, libfreetype6-dev, libboost-all-dev, libglew-dev and libdbus-1-dev...\n"

run_chroot apt-get -y install libpcre3-dev libfreetype6-dev libboost-all-dev libglew-dev libdbus-1-dev

print_msg "Generating Makefile.include...\n"

cat <<EOF > Makefile.include
FLOAT = hard

HOST := arm-linux-gnueabihf
SYSROOT := $(pwd)/$rootfs_dir
SDKSTAGE := \$(SYSROOT)
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
INCLUDES += -isystem\$(SYSROOT)/usr/include -isystem\$(SYSROOT)/opt/vc/include -isystem\$(SYSROOT)/usr/include -isystem\$(SYSROOT)/opt/vc/include/interface/vcos/pthreads -isystem\$(SYSROOT)/opt/vc/include/interface/vmcs_host/linux -isystem\$(SYSROOT)/usr/include/freetype2 -isystem\$(SYSROOT)/usr/include/dbus-1.0 -isystem\$(SYSROOT)/usr/lib/arm-linux-gnueabihf/dbus-1.0/include
EOF

print_msg "Finished!"

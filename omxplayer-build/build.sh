#!/bin/bash
#
# Script for configuring omxplayer compilation and
# creating .deb packages.
#
# Sergio Conde <sergio@sconde.net>
#

DEB_VERSION="UNOFFICIAL~git$(date +%Y%m%d)"

SRC_REPO="https://github.com/popcornmix/omxplayer.git"
SRC_DIR="omxplayer-src"

WORK_DIR=/root/omxplayer-build

raise_error() {
    echo -e "\n[!!!] $@" 1>&2
    exit 1
}

print_status() {
    echo -e "\n[***] $@\n" 1>&2
}

cd $WORK_DIR

# Downloading source
print_status "Obtaining/updating source..."

if [[ ! -d $SRC_DIR ]]; then
    git clone $SRC_REPO $SRC_DIR
    if [[ $? != 0 ]]; then raise_error "git clone failed."; fi

    cd $SRC_DIR
else
    cd $SRC_DIR
    rm -rf omxplayer-dist ffmpeg ffmpeg_compiled

    if [[ $1 == "-f" ]]; then
        git reset --hard HEAD~1
    fi

    git reset --hard HEAD
    if [[ $? != 0 ]]; then raise_error "git reset failed."; fi

    OLD_REV=$(git rev-parse HEAD)

    git pull
    if [[ $? != 0 ]]; then raise_error "git pull failed."; fi

    if [[ $OLD_REV == $(git rev-parse HEAD) ]]; then raise_error "No new versions. If you want force a rebuild exec: `basename $0` -f"; fi
fi

# Patch Makefiles
print_status "Patching Makefiles..."

sed -i 's/INCLUDES+=/INCLUDES+=\$(shell pkg-config --cflags dbus-1 freetype2) /g' Makefile
sed -i 's/\$(CXX) \$(LDFLAGS)/\$(CXX) \$(CFLAGS) \$(INCLUDES) \$(LDFLAGS)/g' Makefile
sed -i 's/\/usr\/share\/doc/\/usr\/share\/doc\/omxplayer/g' Makefile
sed -i '/cd \$(DIST); tar -czf ..\/\$(DIST).tgz \*/d' Makefile

sed -i 's/+\$(MAKE) -C ffmpeg/+\$(MAKE) -C ffmpeg -j5/g' Makefile.ffmpeg
sed -i '/--enable-cross-compile/d' Makefile.ffmpeg
sed -i '/--cross-prefix=$(HOST)-/d' Makefile.ffmpeg

# Use own Makefile.include
cp ../Makefile.include Makefile.include

# Change FFmpeg mirror
#sed -i "s#git://source.ffmpeg.org/ffmpeg#https://github.com/FFmpeg/FFmpeg.git#g" Makefile.ffmpeg

# Compiling OMXPlayer
print_status "Cleaning source tree..."

make clean
if [[ $? != 0 ]]; then raise_error "make clean failed."; fi

print_status "Building ffmpeg..."

make ffmpeg
if [[ $? != 0 ]]; then raise_error "make ffmpeg failed."; fi

print_status "Building omxplayer..."

make -j5
if [[ $? != 0 ]]; then raise_error "make failed."; fi

print_status "Preparing dist..."

make dist
if [[ $? != 0 ]]; then raise_error "make dist failed."; fi

# Setting vars for .deb creation
GIT_VERSION=$(git rev-parse --short $(git symbolic-ref -q HEAD 2> /dev/null) 2> /dev/null)
TOTAL_SIZE=$(du -s omxplayer-dist | sed -r "s/(([0-9])+)(.*)/\1/")

# Copy required files
cp -r $WORK_DIR/DEBIAN $WORK_DIR/$SRC_DIR/omxplayer-dist
#cp $WORK_DIR/omxplayer-fix $WORK_DIR/$SRC_DIR/omxplayer-dist/usr/bin/omxplayer

# Replacing vars in the control file
sed -i "s/PKG_VERSION/${DEB_VERSION}~${GIT_VERSION}/" omxplayer-dist/DEBIAN/control
sed -i "s/TOTAL_SIZE/$TOTAL_SIZE/" omxplayer-dist/DEBIAN/control

# Creating .deb
DEB_FILE="omxplayer_${DEB_VERSION}~${GIT_VERSION}_armhf.deb"

print_status "Generating DEB package: $DEB_FILE"

dpkg-deb -Z xz -b omxplayer-dist $WORK_DIR/$DEB_FILE
if [[ $? != 0 ]]; then raise_error "deb creation failed."; fi

chmod o+r $WORK_DIR/$DEB_FILE

# Resetting source to avoid conflicts in the next build.
print_status "Resetting source tree..."

git reset --hard HEAD
if [[ $? != 0 ]]; then raise_error "git reset failed."; fi

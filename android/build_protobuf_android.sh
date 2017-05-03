#!/bin/bash -x

PB_VERSION=3.2.0

PREFIX=`pwd`/protobuf
mkdir -p ${PREFIX}/platform

#1. Set these variables
export NDK=/Users/radvani/Library/Android/sdk/ndk-bundle/build/tools
export PATH=/Users/radvani/Source/ndk-toolchain/android-23/bin:$PATH
export SYSROOT=/Users/radvani/Source/ndk-toolchain/android-23/sysroot

export CC="arm-linux-androideabi-gcc --sysroot $SYSROOT"
export CXX="arm-linux-androideabi-g++ --sysroot $SYSROOT"
export CXXSTL=$NDK/sources/cxx-stl/gnu-libstdc++/4.6

echo "$(tput setaf 2)"
echo "####################################"
echo " Cleanup any earlier build attempts"
echo "####################################"
echo "$(tput sgr0)"

(
    cd /tmp
    if [ -d ${PREFIX} ]
    then
        rm -rf ${PREFIX}
    fi
    mkdir ${PREFIX}
    mkdir ${PREFIX}/platform
)
 
echo "$(tput setaf 2)"
echo "##########################################"
echo " Fetch Google Protobuf $PB_VERSION from source."
echo "##########################################"
echo "$(tput sgr0)"

(
    cd /tmp

    curl -L https://github.com/google/protobuf/archive/v${PB_VERSION}.tar.gz --output /tmp/protobuf-${PB_VERSION}.tar.gz

    if [ -d /tmp/protobuf-${PB_VERSION} ]
    then
        rm -rf /tmp/protobuf-${PB_VERSION}
    fi
    
    tar xvf /tmp/protobuf-${PB_VERSION}.tar.gz
)

echo "$(tput setaf 2)"
echo "#####################"
echo " armeabi-v7a for Android"
echo "#####################"
echo "$(tput sgr0)"

(
    cd /tmp/protobuf-$PB_VERSION
    ./autogen.sh
    make distclean
    ./configure --prefix=${PREFIX} --host=arm-linux-androideabi --with-sysroot=$SYSROOT  --enable-cross-compile --with-protoc=protoc CFLAGS="-march=armv7-a" CXXFLAGS="-march=armv7-a -I$CXXSTL/include -I$CXXSTL/libs/armeabi-v7a/include" LDFLAGS="-L$(SYSROOT)/usr/lib -llog"
    make
    make install
)

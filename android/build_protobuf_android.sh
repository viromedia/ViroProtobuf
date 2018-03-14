#!/bin/bash -x

PB_VERSION=3.2.0

PREFIX=`pwd`/protobuf
mkdir -p ${PREFIX}/platform/armeabi-v7a
mkdir -p ${PREFIX}/platform/arm64-v8a

#1. Set these variables
export NDK=/Users/radvani/Library/Android/sdk/ndk-bundle/build/tools
export PATH=/Users/radvani/Source/ndk-toolchain/android-23/bin:$PATH

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

# When ready to switch to libc, create a standalone toolchain with the stl flag and add -lstdc++ linker flag below
(
    export SYSROOT=/Users/radvani/Source/ndk-toolchain/android-23/sysroot
    export CC="clang --sysroot $SYSROOT"
    export CXX="clang++ --sysroot $SYSROOT"

    cd /tmp/protobuf-$PB_VERSION
    ./autogen.sh
    make distclean
    ./configure --prefix=${PREFIX}/platform/armeabi-v7a --host=arm-linux-androideabi --with-sysroot=$SYSROOT --enable-cross-compile --with-protoc=protoc CFLAGS="-march=armv7-a" CXXFLAGS="-march=armv7-a" LDFLAGS="-L$(SYSROOT)/usr/lib -llog"
    make -j4
    make install
)

echo "$(tput setaf 2)"
echo "#####################"
echo " arm64-v8a for Android"
echo "#####################"
echo "$(tput sgr0)"

(
    export PATH=/Users/radvani/Source/ndk-toolchain/android-23_arm64/bin:$PATH
    export SYSROOT=/Users/radvani/Source/ndk-toolchain/android-23_arm64/sysroot
    export CC="clang --sysroot $SYSROOT"
    export CXX="clang++ --sysroot $SYSROOT"

    cd /tmp/protobuf-$PB_VERSION
    ./autogen.sh
    make distclean
    ./configure --prefix=${PREFIX}/platform/arm64-v8a --host=arm-linux-androideabi --with-sysroot=$SYSROOT --enable-cross-compile --with-protoc=protoc CFLAGS="" CXXFLAGS="" LDFLAGS="-L$(SYSROOT)/usr/lib -llog"
    make clean
    make -j4
    make install
)

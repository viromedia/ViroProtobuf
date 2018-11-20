#!/bin/bash -x

PB_VERSION=3.2.0

PREFIX=`pwd`/protobuf
mkdir -p ${PREFIX}/platform/armeabi-v7a
mkdir -p ${PREFIX}/platform/arm64-v8a



echo "$(tput setaf 2)"
echo "#####################"
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
echo "###############################################################"
echo " Remove lines with stderr (causes Android compilation error)   "
echo "###############################################################"
echo "$(tput sgr0)"

(
cd /tmp/protobuf-$PB_VERSION/src/google/protobuf/stubs
sed -i '' '/stderr/d' common.cc
cd /tmp
)

echo " armeabi-v7a for Android"
echo "#####################"
echo "$(tput sgr0)"

# When ready to switch to libc, create a standalone toolchain with the stl flag and add -lstdc++ linker flag below
(
    export TOOLCHAIN=/Users/radvani/Source/ndk-toolchain/android-28
    export SYSROOT=$TOOLCHAIN/sysroot
    export PATH=$TOOLCHAIN/bin:$PATH
    TARGET_HOST=arm-linux-androideabi
    export AR=$TARGET_HOST-ar
    export AS=$TARGET_HOST-clang
    export CC=$TARGET_HOST-clang
    export CXX=$TARGET_HOST-clang++
    export LD=$TARGET_HOST-ld
    export STRIP=$TARGET_HOST-strip

    cd /tmp/protobuf-$PB_VERSION
    ./autogen.sh
    make distclean
    ./configure --prefix=${PREFIX}/platform/armeabi-v7a --host=$TARGET_HOST --enable-cross-compile --with-protoc=protoc CFLAGS="-fPIE -fPIC" CXXFLAGS="-fPIE -fPIC" LDFLAGS="-static-libstdc++ -pie -L$(SYSROOT)/usr/lib -llog"
    make -j4
    make install
)

echo "$(tput setaf 2)"
echo "#####################"
echo " arm64-v8a for Android"
echo "#####################"
echo "$(tput sgr0)"

(
    export TOOLCHAIN=/Users/radvani/Source/ndk-toolchain/android-28_arm64
    export SYSROOT=$TOOLCHAIN/sysroot
    export PATH=$TOOLCHAIN/bin:$PATH
    TARGET_HOST=aarch64-linux-android
    export AR=$TARGET_HOST-ar
    export AS=$TARGET_HOST-clang
    export CC=$TARGET_HOST-clang
    export CXX=$TARGET_HOST-clang++
    export LD=$TARGET_HOST-ld
    export STRIP=$TARGET_HOST-strip

    cd /tmp/protobuf-$PB_VERSION
    ./autogen.sh
    make distclean
    ./configure --prefix=${PREFIX}/platform/arm64-v8a --host=$TARGET_HOST --enable-cross-compile --with-protoc=protoc CFLAGS="-fPIE -fPIC" CXXFLAGS="-fPIE -fPIC" LDFLAGS="-static-libstdc++ -pie -L$(SYSROOT)/usr/lib -llog"
    make clean
    make -j4
    make install
)


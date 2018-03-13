#!/bin/bash -x

echo "$(tput setaf 2)"
echo Building Google Protobuf for Mac OS X / iOS.
echo Use 'tail -f build.log' to monitor progress.
echo "$(tput sgr0)"

# Controls which architectures are build/included in the
# universal binaries and libraries this script produces.
# Set each to '1' to include, '0' to exclude. Note that
# MAC must always be 1 because we use the protoc generated
# in the Mac build to generate the tests for the other builds
BUILD_X86_64_MAC=1
BUILD_X86_64_IOS_SIM=1
BUILD_ARMV7_IPHONE=1
BUILD_ARM64_IPHONE=1

PB_VERSION=3.2.0

# Set this to the replacement name for the 'google' namespace.
# This is being done to avoid a conflict with the private
# framework build of Google Protobuf that Apple ships with their
# OpenGL ES framework.
GOOGLE_NAMESPACE=google_public

# Set this to the minimum iOS SDK version you wish to support.
IOS_MIN_SDK=9.1

(

PREFIX=`pwd`/protobuf
mkdir -p ${PREFIX}/platform

###############################
###### MAC BUILD FLAGS ########
###############################

EXTRA_MAKE_FLAGS="-j4"

XCODEDIR=`xcode-select --print-path`

OSX_SDK=$(xcodebuild -showsdks | grep macosx | sort | head -n 1 | awk '{print $NF}')
MACOSX_PLATFORM=${XCODEDIR}/Platforms/MacOSX.platform
MACOSX_SYSROOT=${MACOSX_PLATFORM}/Developer/${OSX_SDK}.sdk

CC=clang
CFLAGS="-DNDEBUG -g -O0 -pipe -fPIC -fcxx-exceptions"
CXX=clang
CXXFLAGS="${CFLAGS} -std=c++11 -stdlib=libc++"
LDFLAGS="-stdlib=libc++"
LIBS="-lc++ -lc++abi"

###############################
###### IOS BUILD FLAGS ########
###############################

OPT_FLAGS="-Os -g3"
MAKE_JOBS=4

dobuild() {
    export CC="$(xcrun -find -sdk ${SDK} cc)"
    export CXX="$(xcrun -find -sdk ${SDK} cxx)"
    export CPP="$(xcrun -find -sdk ${SDK} cpp)"
    export CFLAGS="${HOST_FLAGS} ${OPT_FLAGS}"
    export CXXFLAGS="${HOST_FLAGS} ${OPT_FLAGS}"
    export LDFLAGS="${HOST_FLAGS}"

    ./configure --host=${CHOST} --with-protoc=${PREFIX}/platform/x86_64/bin/protoc --prefix=${PREFIX} --exec-prefix=${PREFIX}/platform/${EXEC_PREFIX} --enable-static --disable-shared

    make clean
    make -j${MAKE_JOBS}
    make install
}

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
echo " Replace 'namespace google' with 'namespace google_public'"
echo " in all source/header files.  This is to address a"
echo " namespace collision issue when building for recent"
echo " versions of iOS.  Apple is using the protobuf library"
echo " internally, and embeds it as a private framework."
echo "###############################################################"
echo "$(tput sgr0)"

(
    cd /tmp/protobuf-$PB_VERSION/src/google/protobuf
    sed -i '' -e "s/namespace\ google /namespace\ ${GOOGLE_NAMESPACE} /g" $(find . -name \*.h -type f)
    sed -i '' -e "s/namespace\ google /namespace\ ${GOOGLE_NAMESPACE} /g" $(find . -name \*.cc -type f)
    sed -i '' -e "s/namespace\ google /namespace\ ${GOOGLE_NAMESPACE} /g" $(find . -name \*.proto -type f)
    sed -i '' -e "s/google::protobuf/${GOOGLE_NAMESPACE}::protobuf/g" $(find . -name \*.h -type f)
    sed -i '' -e "s/google::protobuf/${GOOGLE_NAMESPACE}::protobuf/g" $(find . -name \*.cc -type f)
    sed -i '' -e "s/google::protobuf/${GOOGLE_NAMESPACE}::protobuf/g" $(find . -name \*.proto -type f)
)

if [ $BUILD_X86_64_MAC -eq 1 ]
then

echo "$(tput setaf 2)"
echo "#####################"
echo " x86_64 for Mac OS X"
echo " and python bindings"
echo "#####################"
echo "$(tput sgr0)"

(
    cd /tmp/protobuf-$PB_VERSION
    ./autogen.sh
    make distclean
    ./configure --disable-shared --prefix=${PREFIX} --exec-prefix=${PREFIX}/platform/x86_64 "CC=${CC}" "CFLAGS=${CFLAGS} -arch x86_64" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch x86_64" "LDFLAGS=${LDFLAGS}" "LIBS=${LIBS}"
    make ${EXTRA_MAKE_FLAGS}
    make ${EXTRA_MAKE_FLAGS} test
    make ${EXTRA_MAKE_FLAGS} install
    cd python
    python setup.py build
    python setup.py install --user
)
X86_64_MAC_PROTOBUF=x86_64/lib/libprotobuf.a
X86_64_MAC_PROTOBUF_LITE=x86_64/lib/libprotobuf-lite.a

else

X86_64_MAC_PROTOBUF=
X86_64_MAC_PROTOBUF_LITE=

fi

if [ $BUILD_X86_64_IOS_SIM -eq 1 ]
then

echo "$(tput setaf 2)"
echo "###########################"
echo " x86_64 for iPhone Simulator"
echo "###########################"
echo "$(tput sgr0)"

SDK="iphonesimulator"
EXEC_PREFIX="x86_64_ios"
ARCH_FLAGS="-arch x86_64"
HOST_FLAGS="${ARCH_FLAGS} -mios-simulator-version-min=${IOS_MIN_SDK} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="x86_64-apple-darwin"
cd /tmp/protobuf-$PB_VERSION
./autogen.sh
make distclean
dobuild

X86_64_IOS_SIM_PROTOBUF=${EXEC_PREFIX}/lib/libprotobuf.a
X86_64_IOS_SIM_PROTOBUF_LITE=${EXEC_PREFIX}/lib/libprotobuf-lite.a

else

X86_64_IOS_SIM_PROTOBUF=
X86_64_IOS_SIM_PROTOBUF_LITE=

fi

if [ $BUILD_ARMV7_IPHONE -eq 1 ]
then

echo "$(tput setaf 2)"
echo "##################"
echo " armv7 for iPhone"
echo "##################"
echo "$(tput sgr0)"

SDK="iphoneos"
EXEC_PREFIX="armv7"
ARCH_FLAGS="-arch armv7"
HOST_FLAGS="${ARCH_FLAGS} -miphoneos-version-min=${IOS_MIN_SDK} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="arm-apple-darwin"
cd /tmp/protobuf-$PB_VERSION
./autogen.sh
make distclean
dobuild

ARMV7_IPHONE_PROTOBUF=${EXEC_PREFIX}/lib/libprotobuf.a 
ARMV7_IPHONE_PROTOBUF_LITE=${EXEC_PREFIX}/lib/libprotobuf-lite.a 

else

ARMV7_IPHONE_PROTOBUF=
ARMV7_IPHONE_PROTOBUF_LITE=

fi

if [ $BUILD_ARM64_IPHONE -eq 1 ]
then

echo "$(tput setaf 2)"
echo "##################"
echo " arm64 for iPhone"
echo "##################"
echo "$(tput sgr0)"

SDK="iphoneos"
EXEC_PREFIX="arm64"
ARCH_FLAGS="-arch arm64"
HOST_FLAGS="${ARCH_FLAGS} -miphoneos-version-min=${IOS_MIN_SDK} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path)"
CHOST="arm-apple-darwin"
cd /tmp/protobuf-$PB_VERSION
./autogen.sh
make distclean
dobuild

ARM64_IPHONE_PROTOBUF=${EXEC_PREFIX}/lib/libprotobuf.a 
ARM64_IPHONE_PROTOBUF_LITE=${EXEC_PREFIX}/lib/libprotobuf-lite.a 

else

ARM64_IPHONE_PROTOBUF=
ARM64_IPHONE_PROTOBUF_LITE=

fi

echo "$(tput setaf 2)"
echo "############################"
echo " Create Universal Libraries"
echo "############################"
echo "$(tput sgr0)"

(
    cd ${PREFIX}/platform
    mkdir universal

    lipo ${ARM64_IPHONE_PROTOBUF} ${ARMV7_IPHONE_PROTOBUF} -create -output universal/libprotobuf.a
    lipo ${ARM64_IPHONE_PROTOBUF_LITE} ${ARMV7_IPHONE_PROTOBUF_LITE} -create -output universal/libprotobuf-lite.a
)

echo "$(tput setaf 2)"
echo "########################"
echo " Finalize the packaging"
echo "########################"
echo "$(tput sgr0)"

(
    cd ${PREFIX}
    mkdir bin
    mkdir lib
    cp -r platform/x86_64/bin/protoc bin
    cp -r platform/universal/* lib

    file lib/libprotobuf.a
    file lib/libprotobuf-lite.a
    file lib/libprotoc.a
)

) 2>&1
#) >build.log 2>&1

echo "$(tput setaf 2)"
echo Done!
echo "$(tput sgr0)"

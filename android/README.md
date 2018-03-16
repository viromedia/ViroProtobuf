## Building for Android

****
You *must* have protoc installed on your system for any of this to work! Easy to install with homebrew on Mac.
****

1. Edit the build-protobuf-android.sh script

2. Set PB_VERSION to the probofuf version you want to build. It will be downloaded.

3. Create a standalone NDK toolchain for the platform you're interested in (e.g. android-23 or android-24). Do this from the NDK itself. The following command creates a standalone NDK toolchain in /Users/radvani/Source/ndk-toolchain/android-23, for platform android-23:

```
cd NDK_PATH/build/tools
(on Raj's computer: /Users/radvani/Library/Android/sdk/ndk-bundle/build/tools)

./make-standalone-toolchain.sh --platform=android-23 --install-dir=/Users/radvani/Source/ndk-toolchain/android-23
```

For the arm64_v8a version we need a 64-bit toolchain. Generate this with a similar command:

```
./make-standalone-toolchain.sh --platform=android-23 --arch=arm64 --install-dir=/Users/radvani/Source/ndk-toolchain/android-23_arm64
```

(Note: when ready to switch to libc++ STL, add the -stl=libc++ argument when creating the toolchain)

(NDK path can be found in Android Studio -> Project Structure -> SDK Location -> NDK Location)

4. Back in build-protobuf-android.sh, set variable NDK to your NDK root, and set the other variables under #1:

```
export NDK=YOUR_NDK_ROOT
export PATH=YOUR_NDK_STAND_ALONE_TOOL_PATH/bin:$PATH
export SYSROOT=YOUR_NDK_STAND_ALONE_TOOL_PATH/sysroot
```

5. Run the script. The protobuf/include folder will contain the headers, and the libs will be in protobuf/lib. Use libprotobuf-lite.so.

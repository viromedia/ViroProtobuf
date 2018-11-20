# Building for Android

## Autoconf
## Note: This method NO LONGER WORKS. See method 2 below.

****
You *must* have protoc installed on your system for any of this to work! Easy to install with homebrew on Mac.
****

1. Edit the build-protobuf-android.sh script

2. Set PB_VERSION to the probofuf version you want to build. It will be downloaded.

3. Create a standalone NDK toolchain for the platform you're interested in (e.g. android-28). Do this from the NDK itself. The following command creates a standalone NDK toolchain in /Users/radvani/Source/ndk-toolchain/android-28, for platform android-28:

```
cd NDK_PATH/build/tools
(on Raj's computer: /Users/radvani/Library/Android/sdk/ndk-bundle/build/tools)

python make_standalone_toolchain.py --arch arm --api 28 --install-dir /Users/radvani/Source/ndk-toolchain/android-28
```

For the arm64_v8a version we need a 64-bit toolchain. Generate this with a similar command:

```
python make_standalone_toolchain.py --arch arm64 --api 28 --install-dir /Users/radvani/Source/ndk-toolchain/android-28_arm64
```

(Note: this creates a toolchain with libc++ when using NDK r18 or higher)

(NDK path can be found in Android Studio -> Project Structure -> SDK Location -> NDK Location)

4. Back in build-protobuf-android.sh, set the two TOOLCHAIN variables to point to the toolchains you created.

5. Run the script. The protobuf/include folder will contain the headers, and the libs will be in protobuf/lib. Use libprotobuf-lite.so.


## Building with Android Studio

This method uses a shell application to build the static protobuf libs, which is useful for ensuring you use the same toolchain that's used in your project. This is required because previous attempts to build protobuf using autoconf have failed to make libraries compatible with Android.

### Updating the Protobuf version

1. Download the desired protobuf version
2. Copy the include files into the app/include folder
3. Copy the source files into the src folder (copying the structure already there)
4. Open the Android Studio project
5. Modify CMakeLists if necessary to point to the correct includes or files

### Just Building

1. Open the Android Studio project
2. Select Build Variant Release
3. Make!
4. The output libs will be in build/intermediates/cmake/release/obj

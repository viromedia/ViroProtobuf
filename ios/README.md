## Building for iOS

****
You *must* have protoc installed on your system for any of this to work! Easy to install with homebrew on Mac.
****

To build protobuf for iOS: 

1. Edit the build-protobuf-ios.sh script

2. Set GOOGLE_NAMESPACE to a namespace of choice (we use google_public). This way the protobuf library we build will not conflict with Apple's internal protobuf library.

3. Set the platforms you want to build to 1, e.g. BUILD_I386_IOS_SIM, etc. Note that BUILD_X86_64_MAC is required, do not set it to 0.

4. Set PB_VERSION to the protobuf version you want to build. It will be downloaded.

5. Run the script. The protobuf/include folder will contain the headers, and the libs will be in protobuf/universal. Use libprotobuf-lite.a. (If compiling the simulator, the libs will end up in protobuf/platform/x86_64_ios/lib <-- don't forget the _ios suffix!)

6. For all generated protobuf code (e.g. Nodes.ph.h), redefine the google namespace to the value you set for GOOGLE_NAMESPACE above. Ensure this is *only* added for the iOS build, e.g.:

#include "VRODefines.h"
#if VRO_PLATFORM_IOS
#define google google_public
#endif

For this to work, the .cc protobuf files must also be set to Type: Objective-C++ source

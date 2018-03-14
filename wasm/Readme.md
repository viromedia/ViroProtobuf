Protobuf WebAssembly
-----

Emscripten port of Google's Protobuf library.

## Patching

The 3.1 and 3.2 version of protobuf have been patched, as per the changes found in the diff in the patches directory. If bringing in a new version of protobuf, patch it similarly. Do not worry about patching the Makefile, since we don't use the Makefile for WebAssembly.

## Building

Protobuf is built alongside /ViroRenderer
Copy the source files into /ViroRenderer/wasm/libs/protobuf/src
Edit the CMakeLists there accordingly if there are new files that have been introduced

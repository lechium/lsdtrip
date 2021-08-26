#!/bin/bash

set -e

SDKROOT=`xcrun -sdk macosx --show-sdk-path`
echo $SDKROOT
#xcrun -v -sdk appletvos clang -arch arm64 ls.m -ObjC -all_load -framework Foundation -framework MobileCoreServices -framework UIKit -o lsdtrip

xcrun -v -sdk macosx clang -arch x86_64 -arch arm64 -IFindProcess -I. ls.m FindProcess/LSFindProcess.m -framework Foundation -framework CoreServices -framework AppKit -o lsdtrip.macos


#ldid2 -Sent.plist lsdtrip

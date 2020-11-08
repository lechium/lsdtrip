#!/bin/bash

set -e

SDKROOT=`xcrun -sdk appletvos --show-sdk-path`
echo $SDKROOT
#xcrun -v -sdk appletvos clang -arch arm64 ls.m -ObjC -all_load -framework Foundation -framework MobileCoreServices -framework UIKit -o lsdtrip

xcrun -v -sdk appletvos clang -arch arm64 -IFindProcess -I. ls.m FindProcess/LSFindProcess.m -framework Foundation -framework MobileCoreServices -framework UIKit -o lsdtrip


ldid2 -Sent.plist lsdtrip

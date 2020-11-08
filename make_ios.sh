#!/bin/bash

set -e

SDKROOT=`xcrun -sdk iphoneos --show-sdk-path`
echo $SDKROOT
#xcrun -v -sdk iphoneos clang -fobjc-arc -arch arm64 -IDownload -framework Foundation -framework MobileCoreServices -o nitoInstaller nitoInstaller.m Download/URLDownloader.m Download/URLCredential.m

xcrun -v -sdk iphoneos clang -arch armv7 -arch armv7s -arch arm64 -arch arm64e -IFindProcess -I. ls.m FindProcess/LSFindProcess.m -framework Foundation -framework MobileCoreServices -framework UIKit -o lsdtrip.ios

ldid2 -Sent.plist lsdtrip.ios

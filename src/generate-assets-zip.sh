#!/bin/bash

WORKINGDIR=`PWD`
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PACKAGEDIR=${SRCDIR}/generate-assets
OUTPUTNAME=generate-assets.zip


echo $WORKINGDIR
echo $SRCDIR
echo $PACKAGEDIR
echo $OUTPUTNAME

mkdir "${PACKAGEDIR}" 2>/dev/null

rm -Rf "${SRCDIR}/ios/build"
xcodebuild -project "${SRCDIR}/ios/AIRAssets.xcodeproj/" -scheme AIRAssets build

find "${SRCDIR}" -name .DS_Store -delete
cp -Rf "${SRCDIR}/ios/AIRAssets/Assets.xcassets" "${PACKAGEDIR}/."
cp -Rf "${SRCDIR}/ios/build/Release-iphoneos/AIRAssets.app/Base.lproj/LaunchScreen.storyboardc" "${PACKAGEDIR}/."


cd "${PACKAGEDIR}"
rm -Rf "${WORKINGDIR}/$OUTPUTNAME"
zip -r -q "${WORKINGDIR}/$OUTPUTNAME" *
cd "${WORKINGDIR}"


#!/bin/bash

WORKINGDIR=`PWD`
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PACKAGEDIR=${SCRIPTDIR}/generate-assets
OUTPUTNAME=generate-assets.zip

echo ${WORKINGDIR}
echo ${SCRIPTDIR}
echo ${PACKAGEDIR}
echo ${OUTPUTNAME}

mkdir "${PACKAGEDIR}" 2>/dev/null

rm -Rf "${SCRIPTDIR}/ios/Build"
xcodebuild -quiet -project "${SCRIPTDIR}/ios/AIRAssets.xcodeproj/" -alltargets build

find "${SCRIPTDIR}" -name .DS_Store -delete
cp -Rf "${SCRIPTDIR}/ios/AIRAssets/Assets.xcassets" "${PACKAGEDIR}/." 
cp -Rf "${SCRIPTDIR}/ios/Build/Release-iphoneos/AIRAssets.app/Base.lproj/LaunchScreen.storyboardc" "${PACKAGEDIR}/."

cd "${PACKAGEDIR}"
rm -Rf "${WORKINGDIR}/${OUTPUTNAME}"
zip -r -q "${WORKINGDIR}/${OUTPUTNAME}" *
cd "${WORKINGDIR}"
# rm -Rf "${PACKAGEDIR}"

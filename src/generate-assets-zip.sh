#!/bin/bash
set -e

WORKINGDIR=`PWD`
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ASSET_VERSION=51.5

while [[ $# -gt 0 ]]; do
	case "$1" in
		--asset-version)
			ASSET_VERSION=${2:-}
			if [[ $# -lt 2 ]]; then
				echo "Error: --asset-version requires 51.5 or legacy" >&2
				exit 1
			fi
			shift 2
			;;
		-h|--help)
			echo "Usage: $0 [--asset-version 51.5|legacy] (default: 51.5)"
			exit 0
			;;
		*)
			echo "Error: Unknown option: $1" >&2
			exit 1
			;;
	esac
done

case "$ASSET_VERSION" in
	51.5) OUTPUTNAME=generate-assets-air-51.5.zip ;;
	legacy)
		OUTPUTNAME=generate-assets-v2.zip
		;;
	*)
		echo "Error: --asset-version must be 51.5 or legacy" >&2
		exit 1
		;;
esac

PACKAGEDIR=${SCRIPTDIR}/generate-assets-${ASSET_VERSION}


echo ${WORKINGDIR}
echo ${SCRIPTDIR}
echo ${PACKAGEDIR}
echo ${OUTPUTNAME}

rm -Rf "${PACKAGEDIR}"
mkdir -p "${PACKAGEDIR}"

rm -Rf "${SCRIPTDIR}/ios/Build"
xcodebuild -quiet -project "${SCRIPTDIR}/ios/AIRAssets.xcodeproj/" -alltargets \
	-configuration Release \
	CONFIGURATION_BUILD_DIR="${SCRIPTDIR}/ios/Build/Release-iphoneos" \
	CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build

find "${SCRIPTDIR}" -name .DS_Store -delete
cp -Rf "${SCRIPTDIR}/ios/AIRAssets/Assets.xcassets" "${PACKAGEDIR}/." 
if [[ "$ASSET_VERSION" == 51.5 ]]; then
	rm -Rf "${PACKAGEDIR}/Assets.xcassets/splash_landscape.imageset" \
		"${PACKAGEDIR}/Assets.xcassets/splash_portrait.imageset"
	test -s "${PACKAGEDIR}/Assets.xcassets/air_splash.imageset/Contents.json"
else
	rm -Rf "${PACKAGEDIR}/Assets.xcassets/air_splash.imageset"
	test -s "${PACKAGEDIR}/Assets.xcassets/splash_landscape.imageset/Contents.json"
	test -s "${PACKAGEDIR}/Assets.xcassets/splash_portrait.imageset/Contents.json"
fi
cp -Rf "${SCRIPTDIR}/ios/Build/Release-iphoneos/AIRAssets.app/Base.lproj/LaunchScreen.storyboardc" "${PACKAGEDIR}/."
cp -Rf "${SCRIPTDIR}/android/res" "${PACKAGEDIR}/."

cd "${PACKAGEDIR}"
rm -Rf "${WORKINGDIR}/${OUTPUTNAME}"
zip -r -q "${WORKINGDIR}/${OUTPUTNAME}" *
cd "${WORKINGDIR}"
# rm -Rf "${PACKAGEDIR}"

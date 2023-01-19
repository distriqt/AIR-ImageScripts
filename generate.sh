#!/bin/bash

# Uses imagemagick 
# brew install imagemagick

# Usage
# -------------------------------------------
# Example: `generate.sh icon.png launch.png "#ff0000" src`

usage() { echo "usage: $0 icon_image launch_image fill_bg_color [dst_dir]"; exit 1; }

ICON=$(readlink -f ${1:-"icon.png"})
ICON_ALT="icon-alt.png"
LAUNCH=$(readlink -f ${2:-"launch.png"})
FILL_COLOUR=${3:-"none"}    
OUTPUT=${4:-"out"}

if [ ! -f "$ICON" ]; then 
    usage
fi

echo "USING:"
echo "  icon=$ICON"
echo "  launch=$LAUNCH"

# set -x

# Directories
# -------------------------------------------

SCRIPTDIR=`dirname $0`
WORKINGDIR=`PWD`
ASSETSDIR=${WORKINGDIR}/.air-icon-generation-assets
ASSETSSRCDIR=${ASSETSDIR}/src
ASSETSWORKING=${ASSETSDIR}/build

mkdir -p "${OUTPUT}"  2>/dev/null
mkdir -p "${ASSETSSRCDIR}"  2>/dev/null

OUTPUTDIR=$(readlink -f ${OUTPUT})
if [ ! -d "${OUTPUTDIR}" ]; then 
    echo "No output dir: ${OUTPUTDIR}"
    usage 
fi



# Download xcassets
# -------------------------------------------
if [ ! -d "${ASSETSSRCDIR}/Assets.xcassets" ]; then 
    echo "Downloading assets"
    until $(curl -L "https://github.com/distriqt/AIR-ImageScripts/blob/master/generate-assets.zip?raw=true" --output .tmp.generate-assets.zip); do
        printf '.'
        sleep 5
    done
    # curl -L "https://github.com/distriqt/AIR-ImageScripts/blob/master/generate-assets.zip?raw=true" --output .tmp.generate-assets.zip
    unzip -qq -o .tmp.generate-assets.zip -d "${ASSETSSRCDIR}"
    rm -Rf .tmp.generate-assets.zip
fi


# App Icons
# -------------------------------------------
echo "Generating icons"
c="convert -background none"

ICONDIR=${OUTPUTDIR}/icons
mkdir -p "${ICONDIR}"

$c "$ICON" -resize 16x16 "$ICONDIR/icon16x16.png"
$c "$ICON" -resize 20x20 "$ICONDIR/icon20x20.png"
$c "$ICON" -resize 29x29 "$ICONDIR/icon29x29.png"
$c "$ICON" -resize 32x32 "$ICONDIR/icon32x32.png"
$c "$ICON" -resize 36x36 "$ICONDIR/icon36x36.png"
$c "$ICON" -resize 40x40 "$ICONDIR/icon40x40.png"
$c "$ICON" -resize 48x48 "$ICONDIR/icon48x48.png"
$c "$ICON" -resize 57x57 "$ICONDIR/icon57x57.png"
$c "$ICON" -resize 58x58 "$ICONDIR/icon58x58.png"
$c "$ICON" -resize 60x60 "$ICONDIR/icon60x60.png"
$c "$ICON" -resize 64x64 "$ICONDIR/icon64x64.png"
$c "$ICON" -resize 72x72 "$ICONDIR/icon72x72.png"
$c "$ICON" -resize 76x76 "$ICONDIR/icon76x76.png"
$c "$ICON" -resize 80x80 "$ICONDIR/icon80x80.png"
$c "$ICON" -resize 87x87 "$ICONDIR/icon87x87.png"
$c "$ICON" -resize 114x114 "$ICONDIR/icon114x114.png"
$c "$ICON" -resize 120x120 "$ICONDIR/icon120x120.png"
$c "$ICON" -resize 128x128 "$ICONDIR/icon128x128.png"
$c "$ICON" -resize 144x144 "$ICONDIR/icon144x144.png"
$c "$ICON" -resize 152x152 "$ICONDIR/icon152x152.png"
$c "$ICON" -resize 167x167 "$ICONDIR/icon167x167.png"
$c "$ICON" -resize 180x180 "$ICONDIR/icon180x180.png"
$c "$ICON" -resize 256x256 "$ICONDIR/icon512x512.png"
$c "$ICON" -resize 512x512 "$ICONDIR/icon512x512.png"
$c "$ICON" -resize 1024x1024 "$ICONDIR/icon1024x1024.png"



# Assets.car
# -------------------------------------------

echo "Generating Assets.car"
echo " - Assets.car: Icons"

c="convert -background none"

TMPDIR=${WORKINGDIR}/.air-icon-generation-tmp
if [ -d "${TMPDIR}" ]; then 
    echo "delete ${TMPDIR}"
    rm -Rf "${TMPDIR}"
fi
mkdir "${TMPDIR}" 2>/dev/null
if [ -d "${ASSETSWORKING}" ]; then 
    echo "delete ${ASSETSWORKING}"
    rm -Rf "${ASSETSWORKING}"
fi
cp -Rf "${ASSETSSRCDIR}" "${ASSETSWORKING}"

generate_appicon () {
    ICONSRC=$1
    ICONNAME=$2
    APPICONSETSRC="${ASSETSSRCDIR}/Assets.xcassets/AppIcon.appiconset"
    APPICONSET="${ASSETSWORKING}/Assets.xcassets/${ICONNAME}.appiconset"

    if [ ! -d "${APPICONSET}" ]; then 
        echo "generate_appicon: ${ICONNAME}.appiconset doesn't exist - creating new icon set"
        mkdir "${APPICONSET}"
    fi

    cp -Rf "${ASSETSSRCDIR}/Assets.xcassets/AppIcon.appiconset/Contents.json" "${APPICONSET}/Contents.json"
    sed -i.bak "s/Icon-App/${ICONNAME}/" "${APPICONSET}/Contents.json"

    rm -f ${APPICONSET}/Icon-App*
    rm -f ${APPICONSET}/Contents.json.bak

    $c "${ICONSRC}" -resize 20x20   "${APPICONSET}/${ICONNAME}-20x20@1x.png"
    $c "${ICONSRC}" -resize 40x40   "${APPICONSET}/${ICONNAME}-20x20@2x.png"
    $c "${ICONSRC}" -resize 60x60   "${APPICONSET}/${ICONNAME}-20x20@3x.png"
    $c "${ICONSRC}" -resize 29x29   "${APPICONSET}/${ICONNAME}-29x29@1x.png"
    $c "${ICONSRC}" -resize 58x58   "${APPICONSET}/${ICONNAME}-29x29@2x.png"
    $c "${ICONSRC}" -resize 87x87   "${APPICONSET}/${ICONNAME}-29x29@3x.png"
    $c "${ICONSRC}" -resize 40x40   "${APPICONSET}/${ICONNAME}-40x40@1x.png"
    $c "${ICONSRC}" -resize 80x80   "${APPICONSET}/${ICONNAME}-40x40@2x.png"
    $c "${ICONSRC}" -resize 120x120 "${APPICONSET}/${ICONNAME}-40x40@3x.png"
    $c "${ICONSRC}" -resize 120x120 "${APPICONSET}/${ICONNAME}-60x60@2x.png"
    $c "${ICONSRC}" -resize 180x180 "${APPICONSET}/${ICONNAME}-60x60@3x.png"
    $c "${ICONSRC}" -resize 76x76   "${APPICONSET}/${ICONNAME}-76x76@1x.png"
    $c "${ICONSRC}" -resize 152x152 "${APPICONSET}/${ICONNAME}-76x76@2x.png"
    $c "${ICONSRC}" -resize 167x167 "${APPICONSET}/${ICONNAME}-83.5x83.5@2x.png"

    $c "${ICONSRC}" -resize 1024x1024 "${APPICONSET}/iTunesArtwork@2x.png"

    echo " - Assets.car: ${ICONNAME} created"

}

generate_appicon "${ICON}" "AppIcon" 

# If you have an "icon-alt.png" in the directory this will add an alternate icon to the asset catalogue (for dynamic icons)
# To add another duplicate this section and change the source and name of the icon
if [ -f "$ICON_ALT" ]; then 
    generate_appicon "${ICON_ALT}" "AlternateIcon" 
fi

echo " - Assets.car: launch screen"

LAUNCHSET=$ASSETSWORKING/Assets.xcassets/LaunchImage.imageset

if [ -f "${LAUNCH}" ]; then
    convert ${LAUNCH} -resize 2400x2400 "${LAUNCHSET}/LaunchImage.png" 2>/dev/null
else 
    c="convert ${ICON} -background ${FILL_COLOUR} -gravity center"
    $c -resize 1024x1024 -extent 2400x2400 "${LAUNCHSET}/LaunchImage.png"
fi

echo " - Assets.car: actool"

xcrun actool "${ASSETSWORKING}/Assets.xcassets" --compile "${TMPDIR}" \
    --platform iphoneos \
    --minimum-deployment-target 9.0 \
    --include-all-app-icons \
    --app-icon AppIcon \
    --output-partial-info-plist "${TMPDIR}/partial.plist" 1>/dev/null 2>/dev/null

echo " - Assets.car: actool complete"

cp -Rf "${TMPDIR}/Assets.car" "${OUTPUTDIR}/."
cp -Rf "${ASSETSWORKING}/LaunchScreen.storyboardc" "${OUTPUTDIR}/."

echo "========== COMPLETE =============="


# List contents of asset catalogue
#xcrun --sdk iphoneos assetutil --info "${OUTPUTDIR}/Assets.car"
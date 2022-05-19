#!/bin/bash

# Uses imagemagick 
# brew install imagemagick

# Usage
# -------------------------------------------
# Example: `generate.sh icon.png launch.png "#ff0000" src`

usage() { echo "usage: $0 icon_image launch_image fill_bg_color [dst_dir]"; exit 1; }

ICON=${1:-"icon.png"}
LAUNCH=${2:-"launch.png"}
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
ASSETSDIR=$WORKINGDIR/assets
OUTPUTDIR=$WORKINGDIR/$OUTPUT

mkdir "$OUTPUTDIR"  2>/dev/null
mkdir "$ASSETSDIR"  2>/dev/null



# Download xcassets
# -------------------------------------------
if [ ! -d "$ASSETSDIR/Assets.xcassets" ]; then 
    echo "Downloading assets"
    curl -L "https://github.com/distriqt/AIR-ImageScripts/blob/master/generate-assets.zip?raw=true" --output .tmp.generate-assets.zip
    unzip -o .tmp.generate-assets.zip -d "$ASSETSDIR"
    rm -Rf .tmp.generate-assets.zip
fi


# App Icons
# -------------------------------------------
echo "Generating icons"
c="convert -background none"

ICONDIR=$OUTPUTDIR/icons
mkdir -p "$ICONDIR"

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
$c "$ICON" -resize 512x512 "$ICONDIR/icon512x512.png"
$c "$ICON" -resize 1024x1024 "$ICONDIR/icon1024x1024.png"



# Assets.car
# -------------------------------------------

echo "Generating Assets.car"
echo " - Assets.car: Icons"

c="convert -background none"

TMPDIR=$WORKINGDIR/tmp

rm -Rf "$TMPDIR"
mkdir "$TMPDIR"

ASSETICONS=$ASSETSDIR/Assets.xcassets/AppIcon.appiconset
LAUNCHSET=$ASSETSDIR/Assets.xcassets/LaunchImage.imageset

$c "$ICON" -resize 20x20   "$ASSETICONS/Icon-App-20x20@1x.png"
$c "$ICON" -resize 40x40   "$ASSETICONS/Icon-App-20x20@2x.png"
$c "$ICON" -resize 60x60   "$ASSETICONS/Icon-App-20x20@3x.png"
$c "$ICON" -resize 29x29   "$ASSETICONS/Icon-App-29x29@1x.png"
$c "$ICON" -resize 58x58   "$ASSETICONS/Icon-App-29x29@2x.png"
$c "$ICON" -resize 87x87   "$ASSETICONS/Icon-App-29x29@3x.png"
$c "$ICON" -resize 40x40   "$ASSETICONS/Icon-App-40x40@1x.png"
$c "$ICON" -resize 80x80   "$ASSETICONS/Icon-App-40x40@2x.png"
$c "$ICON" -resize 120x120 "$ASSETICONS/Icon-App-40x40@3x.png"
$c "$ICON" -resize 120x120 "$ASSETICONS/Icon-App-60x60@2x.png"
$c "$ICON" -resize 180x180 "$ASSETICONS/Icon-App-60x60@3x.png"
$c "$ICON" -resize 76x76   "$ASSETICONS/Icon-App-76x76@1x.png"
$c "$ICON" -resize 152x152 "$ASSETICONS/Icon-App-76x76@2x.png"
$c "$ICON" -resize 167x167 "$ASSETICONS/Icon-App-83.5x83.5@2x.png"

# $c "$ICON" -resize 48x48   "$ASSETICONS/Icon-24@2x.png"
# $c "$ICON" -resize 55x55   "$ASSETICONS/Icon-27.5@2x.png"
# $c "$ICON" -resize 58x58   "$ASSETICONS/Icon-29@2x.png"
# $c "$ICON" -resize 87x87   "$ASSETICONS/Icon-29@3x.png"
# $c "$ICON" -resize 80x80   "$ASSETICONS/Icon-40@2x.png"
# $c "$ICON" -resize 88x88   "$ASSETICONS/Icon-44@2x.png"
# $c "$ICON" -resize 172x172 "$ASSETICONS/Icon-86@2x.png"
# $c "$ICON" -resize 196x196 "$ASSETICONS/Icon-98@2x.png"

# $c "$ICON" -resize 512x512   "$ASSETICONS/iTunesArtwork.png"
$c "$ICON" -resize 1024x1024 "$ASSETICONS/iTunesArtwork@2x.png"

echo " - Assets.car: Icons created"

if [ -f "$LAUNCH" ]; then
    convert $LAUNCH -resize 2400x2400 "$LAUNCHSET/LaunchImage.png"
else 
    c="convert $ICON -background $FILL_COLOUR -gravity center"
    $c -resize 1024x1024 -extent 2400x2400 "$LAUNCHSET/LaunchImage.png"
fi

echo " - Assets.car: actool"

xcrun actool "$ASSETSDIR/Assets.xcassets" --compile "$TMPDIR" \
    --platform iphoneos \
    --minimum-deployment-target 9.0 \
    --app-icon AppIcon \
    --output-partial-info-plist "$TMPDIR/partial.plist" 1>/dev/null 2>/dev/null

echo " - Assets.car: actool complete"

cp -Rf "$TMPDIR/Assets.car" "$OUTPUTDIR/."
cp -Rf "$ASSETSDIR/LaunchScreen.storyboardc" "$OUTPUTDIR/."
rm -Rf "$TMPDIR"


echo "========== COMPLETE =============="

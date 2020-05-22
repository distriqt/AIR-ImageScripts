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

echo "icon=$ICON"
echo "launch=$LAUNCH"

set -x

# Directories
# -------------------------------------------

SCRIPTDIR=`dirname $0`
WORKINGDIR=`PWD`
OUTPUTDIR=$WORKINGDIR/$OUTPUT

mkdir $OUTPUTDIR  



# Download xcassets
# -------------------------------------------
if [ ! -d "$WORKINGDIR/Assets.xcassets" ]; then 
    curl https://airnativeextensions.github.io/tutorials/resources/ios/assets-car-build.zip --output .tmp.assets-car-build.zip
    unzip -o .tmp.assets-car-build.zip 'assets-car-build/Assets.xcassets/*' -d "$WORKINGDIR"
    mv $WORKINGDIR/assets-car-build/Assets.xcassets .
    rm -Rf assets-car-build
    rm -Rf .tmp.assets-car-build.zip
fi


# App Icons
# -------------------------------------------
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


# Default Images
# -------------------------------------------

LAUNCHIMAGEDIR=$OUTPUTDIR
mkdir -p "$LAUNCHIMAGEDIR"

if [ -f $LAUNCH ]; then
    # Resize to correct dimensions keeping aspect and cropping
    c="convert $LAUNCH"

    # iPhone
    $c -resize 320x480^ -extent 320x480  "$LAUNCHIMAGEDIR/Default~iphone.png"
    $c -resize 640x960^ -extent 640x960  "$LAUNCHIMAGEDIR/Default@2x~iphone.png"
    $c -resize 640x1136^ -extent 640x1136 "$LAUNCHIMAGEDIR/Default-568h@2x~iphone.png"
    $c -resize 750x1334^ -extent 750x1334  "$LAUNCHIMAGEDIR/Default-375w-667h@2x~iphone.png"
    $c -resize 1242x2208^ -extent 1242x2208 "$LAUNCHIMAGEDIR/Default-414w-736h@3x~iphone.png"
    $c -resize 2208x1242^ -extent 2208x1242 "$LAUNCHIMAGEDIR/Default-Landscape-414w-736h@3x~iphone.png"
    $c -resize 1125x2436^ -extent 1125x2436 "$LAUNCHIMAGEDIR/Default-812h@3x~iphone.png"
    $c -resize 2436x1125^ -extent 2436x1125 "$LAUNCHIMAGEDIR/Default-Landscape-812h@3x~iphone.png"

    # iPad
    $c -resize 768x1024^   -extent 768x1024  "$LAUNCHIMAGEDIR/Default-Portrait~ipad.png"
    $c -resize 1024x768^   -extent 1024x768  "$LAUNCHIMAGEDIR/Default-Landscape~ipad.png"
    $c -resize 1536x2048^ -extent 1536x2048 "$LAUNCHIMAGEDIR/Default-Portrait@2x~ipad.png"
    $c -resize 2048x1536^ -extent 2048x1536 "$LAUNCHIMAGEDIR/Default-Landscape@2x~ipad.png"
    $c -resize 1668x2224^ -extent 1668x2224 "$LAUNCHIMAGEDIR/Default-Portrait-1112h@2x.png"
    $c -resize 2224x1668^ -extent 2224x1668 "$LAUNCHIMAGEDIR/Default-Landscape-1112h@2x.png"
    $c -resize 2048x2732^ -extent 2048x2732 "$LAUNCHIMAGEDIR/Default-Portrait@2x.png"
    $c -resize 2732x2048^ -extent 2732x2048 "$LAUNCHIMAGEDIR/Default-Landscape@2x.png"

else 
    # center icon in launch image area and fill with colour

    c="convert $ICON -background $FILL_COLOUR -gravity center"

    # iPhone
    $c -resize 256x256 -extent 320x480  "$LAUNCHIMAGEDIR/Default~iphone.png"
    $c -resize 512x512 -extent 640x960  "$LAUNCHIMAGEDIR/Default@2x~iphone.png"
    $c -resize 512x512 -extent 640x1136 "$LAUNCHIMAGEDIR/Default-568h@2x~iphone.png"
    $c -resize 512x512 -extent 750x1334  "$LAUNCHIMAGEDIR/Default-375w-667h@2x~iphone.png"
    $c -resize 1024x1024 -extent 1242x2208 "$LAUNCHIMAGEDIR/Default-414w-736h@3x~iphone.png"
    $c -resize 1024x1024 -extent 2208x1242 "$LAUNCHIMAGEDIR/Default-Landscape-414w-736h@3x~iphone.png"
    $c -resize 1024x1024 -extent 1125x2436 "$LAUNCHIMAGEDIR/Default-812h@3x~iphone.png"
    $c -resize 1024x1024 -extent 2436x1125 "$LAUNCHIMAGEDIR/Default-Landscape-812h@3x~iphone.png"

    # iPad
    $c -resize 512x512   -extent 768x1024  "$LAUNCHIMAGEDIR/Default-Portrait~ipad.png"
    $c -resize 512x512   -extent 1024x768  "$LAUNCHIMAGEDIR/Default-Landscape~ipad.png"
    $c -resize 1024x1024 -extent 1536x2048 "$LAUNCHIMAGEDIR/Default-Portrait@2x~ipad.png"
    $c -resize 1024x1024 -extent 2048x1536 "$LAUNCHIMAGEDIR/Default-Landscape@2x~ipad.png"
    $c -resize 1024x1024 -extent 1668x2224 "$LAUNCHIMAGEDIR/Default-Portrait-1112h@2x.png"
    $c -resize 1024x1024 -extent 2224x1668 "$LAUNCHIMAGEDIR/Default-Landscape-1112h@2x.png"
    $c -resize 1024x1024 -extent 2048x2732 "$LAUNCHIMAGEDIR/Default-Portrait@2x.png"
    $c -resize 1024x1024 -extent 2732x2048 "$LAUNCHIMAGEDIR/Default-Landscape@2x.png"

fi




# Assets.car
# -------------------------------------------
c="convert -background none"

TMPDIR=$SCRIPTDIR/tmp

rm -Rf $TMPDIR
mkdir $TMPDIR

ASSETICONS=$WORKINGDIR/Assets.xcassets/AppIcon.appiconset
LAUNCHSET=$WORKINGDIR/Assets.xcassets/LaunchImage.imageset

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

$c "$ICON" -resize 48x48   "$ASSETICONS/Icon-24@2x.png"
$c "$ICON" -resize 55x55   "$ASSETICONS/Icon-27.5@2x.png"
$c "$ICON" -resize 58x58   "$ASSETICONS/Icon-29@2x.png"
$c "$ICON" -resize 87x87   "$ASSETICONS/Icon-29@3x.png"
$c "$ICON" -resize 80x80   "$ASSETICONS/Icon-40@2x.png"
$c "$ICON" -resize 88x88   "$ASSETICONS/Icon-44@2x.png"
$c "$ICON" -resize 172x172 "$ASSETICONS/Icon-86@2x.png"
$c "$ICON" -resize 196x196 "$ASSETICONS/Icon-98@2x.png"

$c "$ICON" -resize 512x512   "$ASSETICONS/iTunesArtwork.png"
$c "$ICON" -resize 1024x1024 "$ASSETICONS/iTunesArtwork@2x.png"


if [ -f "$LAUNCH" ]; then
    cp "$LAUNCH" "$LAUNCHSET/LaunchImage.png"
else 
    cp "$LAUNCHIMAGEDIR/Default-Portrait@2x.png" "$LAUNCHSET/LaunchImage.png"
fi


xcrun actool $SCRIPTDIR/Assets.xcassets --compile $TMPDIR --platform iphoneos --minimum-deployment-target 8.0 --app-icon AppIcon --output-partial-info-plist $TMPDIR/partial.plist
cp -Rf $TMPDIR/Assets.car $OUTPUTDIR/.
rm -Rf $TMPDIR

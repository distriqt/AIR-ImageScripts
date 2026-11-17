#!/bin/bash
set -euo pipefail

TEST_DIR=$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
REPO_DIR=$(cd -P "${TEST_DIR}/.." && pwd -P)
GENERATOR=${REPO_DIR}/generateIcons
SAMPLE_DIR=${REPO_DIR}/example
TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/air-image-scripts-test.XXXXXX")
SOURCE_DIR="${TEMP_ROOT}/source images"
OUTPUT_DIR="${TEMP_ROOT}/output images"
ASSET_SOURCE=${SOURCE_DIR}/.air-icon-generation-assets-51.5/src

trap 'rm -rf "${TEMP_ROOT}"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

assert_file() {
    [ -f "$1" ] || fail "Expected file: $1"
}

assert_dimensions() {
    local image=$1
    local expected=$2
    local actual

    actual=$(magick identify -format '%wx%h' "$image")
    [ "$actual" = "$expected" ] || fail "Expected ${image} to be ${expected}; got ${actual}"
}

mkdir -p "$ASSET_SOURCE" "$OUTPUT_DIR"
cp "${SAMPLE_DIR}/icon-foreground.png" \
    "${SAMPLE_DIR}/icon-background.png" \
    "${SAMPLE_DIR}/icon-monochrome.png" \
    "${SAMPLE_DIR}/icon-dark.png" \
    "${SAMPLE_DIR}/launch.png" \
    "$SOURCE_DIR/"
cp -R "${REPO_DIR}/src/generate-assets-51.5/." "$ASSET_SOURCE/"
LEGACY_ASSET_SOURCE=${SOURCE_DIR}/.air-icon-generation-assets-v2/src
mkdir -p "$LEGACY_ASSET_SOURCE"
cp -R "${REPO_DIR}/src/generate-assets-legacy/." "$LEGACY_ASSET_SOURCE/"

run_generator() {
    local log_file=$1
    shift

    if ! bash "$GENERATOR" --source "$SOURCE_DIR" --output "$OUTPUT_DIR" "$@" >"$log_file" 2>&1; then
        cat "$log_file" >&2
        fail "generateIcons failed; see output above"
    fi
}

run_generator "${TEMP_ROOT}/fallback.log" --launch "${SOURCE_DIR}/missing-launch.png"

assert_file "${OUTPUT_DIR}/icons/icon1024x1024.png"
assert_dimensions "${OUTPUT_DIR}/icons/icon1024x1024.png" "1024x1024"
assert_file "${OUTPUT_DIR}/res/mipmap-mdpi/icon.png"
assert_dimensions "${OUTPUT_DIR}/res/mipmap-mdpi/icon.png" "48x48"

if [[ "${OSTYPE}" == "darwin"* ]]; then
    assert_file "${OUTPUT_DIR}/Assets.car"
    assert_file "${OUTPUT_DIR}/LaunchScreen.storyboardc/Info.plist"
    FALLBACK_IMAGE=${SOURCE_DIR}/.air-icon-generation-assets-51.5/build/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
    assert_file "$FALLBACK_IMAGE"
    assert_dimensions "$FALLBACK_IMAGE" "2400x2400"

    alpha_mean=$(magick "$FALLBACK_IMAGE" -alpha extract -format '%[fx:mean]' info:)
    awk -v mean="$alpha_mean" 'BEGIN { exit !(mean > 0.99) }' \
        || fail "Expected fallback launch image to have an opaque background; alpha mean was ${alpha_mean}"
fi

run_generator "${TEMP_ROOT}/supplied-launch.log" --launch "launch.png"

if ! grep -q "using supplied launch image" "${TEMP_ROOT}/supplied-launch.log"; then
    fail "Expected supplied launch image path to be used"
fi

assert_file "$ASSET_SOURCE/Assets.xcassets/air_splash.imageset/Contents.json"
[ ! -e "$ASSET_SOURCE/Assets.xcassets/splash_portrait.imageset" ] || fail "Default assets include legacy splash"
run_generator "${TEMP_ROOT}/legacy.log" --asset-version legacy
assert_file "$LEGACY_ASSET_SOURCE/Assets.xcassets/splash_portrait.imageset/Contents.json"
assert_file "$LEGACY_ASSET_SOURCE/Assets.xcassets/splash_landscape.imageset/Contents.json"
[ ! -e "$LEGACY_ASSET_SOURCE/Assets.xcassets/air_splash.imageset" ] || fail "Legacy assets include new splash"
if [[ "${OSTYPE}" == "darwin"* ]]; then
    assert_file "${OUTPUT_DIR}/Assets.car"
fi
for version in invalid ''; do
    if bash "$GENERATOR" --asset-version "$version" >"${TEMP_ROOT}/invalid.log" 2>&1; then
        fail "Expected invalid asset version to fail"
    fi
done

if [[ "${OSTYPE}" == "darwin"* ]]; then
    mkdir -p "${TEMP_ROOT}/failing-tools"
    printf '#!/bin/bash\nexit 1\n' > "${TEMP_ROOT}/failing-tools/xcrun"
    chmod +x "${TEMP_ROOT}/failing-tools/xcrun"
    if PATH="${TEMP_ROOT}/failing-tools:${PATH}" bash "$GENERATOR" \
        --source "$SOURCE_DIR" --output "$OUTPUT_DIR" >"${TEMP_ROOT}/failure.log" 2>&1; then
        fail "Expected actool failure to fail generation even with existing output"
    fi
    grep -q "iOS asset generation failed" "${TEMP_ROOT}/failure.log" \
        || fail "Expected an explicit iOS generation error"
fi

mkdir -p "${TEMP_ROOT}/download-tools"
printf '%s\n' '#!/bin/bash' \
    'while [[ $# -gt 0 ]]; do' \
    '    case "$1" in' \
    '        --output) output=$2; shift 2 ;;' \
    '        https://*) printf "%s\n" "$1" > "$DOWNLOAD_LOG"; shift ;;' \
    '        *) shift ;;' \
    '    esac' \
    'done' \
    'cp "$TEST_ARCHIVE" "$output"' > "${TEMP_ROOT}/download-tools/curl"
chmod +x "${TEMP_ROOT}/download-tools/curl"
rm -Rf "${SOURCE_DIR}/.air-icon-generation-assets-51.5" "${SOURCE_DIR}/.air-icon-generation-assets-v2"
for version in 51.5 legacy; do
    if [[ "$version" == 51.5 ]]; then
        archive=generate-assets-air-51.5.zip
        expected_url="https://github.com/distriqt/AIR-ImageScripts/releases/latest/download/$archive"
    else
        archive=generate-assets-v2.zip
        expected_url="https://github.com/distriqt/AIR-ImageScripts/releases/download/v2.0/$archive"
    fi
    PATH="${TEMP_ROOT}/download-tools:${PATH}" TEST_ARCHIVE="${REPO_DIR}/$archive" \
        DOWNLOAD_LOG="${TEMP_ROOT}/download-url" \
        run_generator "${TEMP_ROOT}/download-$version.log" --asset-version "$version"
    [[ $(<"${TEMP_ROOT}/download-url") == "$expected_url" ]] || fail "Wrong download URL for $version"
done

mkdir -p "$ASSET_SOURCE/Assets.xcassets/splash_landscape.imageset"
if bash "$GENERATOR" --source "$SOURCE_DIR" --output "$OUTPUT_DIR" >"${TEMP_ROOT}/mixed-cache.log" 2>&1; then
    fail "Expected mixed template cache to fail"
fi
grep -q "Cached templates do not match" "${TEMP_ROOT}/mixed-cache.log" || fail "Expected cache mismatch error"

echo "PASS: both asset formats, downloads, caches, icon sizes, launch images, and iOS failures"
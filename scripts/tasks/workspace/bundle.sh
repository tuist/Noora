#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR=$($SCRIPT_DIR/../../utilities/root_dir.sh)
TMP_DIR=/private$(mktemp -d)
# trap "rm -rf $TMP_DIR" EXIT

echo $TMP_DIR
XCODE_BUILD_DIR=$TMP_DIR/build
DERIVED_DATA_PATH=$TMP_DIR/derived_data
BUILD_DIR=$ROOT_DIR/build

tuist install --path $ROOT_DIR
tuist generate --path $ROOT_DIR --no-open
xcrun xcodebuild -scheme macker -configuration Release -derivedDataPath $DERIVED_DATA_PATH -destination platform=macosx BUILD_LIBRARY_FOR_DISTRIBUTION=YES ARCHS='arm64 x86_64' BUILD_DIR=$XCODE_BUILD_DIR clean build

mkdir -p $BUILD_DIR
cp $XCODE_BUILD_DIR/Release/macker $BUILD_DIR/macker

(
    cd $BUILD_DIR || exit 1
    zip -q -r --symlinks macker.zip macker

    : > SHASUMS256.txt
    : > SHASUMS512.txt

    for file in *; do
        if [ -f "$file" ]; then
            if [[ "$file" == "SHASUMS256.txt" || "$file" == "SHASUMS512.txt" ]]; then
                continue
            fi
            echo "$(shasum -a 256 "$file" | awk '{print $1}') ./$file" >> SHASUMS256.txt
            echo "$(shasum -a 512 "$file" | awk '{print $1}') ./$file" >> SHASUMS512.txt
        fi
    done
)
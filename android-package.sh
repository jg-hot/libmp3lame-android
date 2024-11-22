#!/usr/bin/env bash
ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

# ./android-build.sh

rm -r build/aar/prefab/
mkdir -vp build/aar/prefab/

# copy metadata files
cp -vrt build/aar/prefab/ android/prefab-template/*

# make prefab package
pushd build
    # copy headers
    mkdir -vp aar/prefab/modules/mp3lame/include/
    cp -vt aar/prefab/modules/mp3lame/include/ include/lame/*.h

    # copy libraries
    for ABI in ${ABIS[@]}; do
        cp -vt aar/prefab/modules/mp3lame/libs/android.$ABI/ $ABI/lib/*.so
    done

    # verify prefab package
    for ABI in ${ABIS[@]}; do
        (set -x; prefab \
            --build-system cmake \
            --platform android \
            --os-version 21 \
            --ndk-version 27 \
            --stl none \
            --abi ${ABI} \
            --output $(pwd)/tmp/prefab-verification \
            $(pwd)/aar/prefab)

        RESULT=$?; if [[ $RESULT == 0 ]]; then
            echo "$ABI: prefab package verified"
        else
            echo "$ABI: package package verification failed"
            exit 1
        fi

        rm -r tmp/
    done
popd

AAR_NAME="lame-3.100-android-r1.aar"

# zip prefab/ and AndroidManifest.xml into an .aar
cp -vt build/aar/ android/AndroidManifest.xml

pushd build/aar
    zip -r "../$AAR_NAME" . > /dev/null
popd

# verify .aar and print output path to console
unzip -t "build/$AAR_NAME"

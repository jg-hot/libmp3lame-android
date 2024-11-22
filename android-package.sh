#!/usr/bin/env bash
ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

# ./build_all_android.sh

rm -r build/prefab
mkdir -p build/prefab

# make prefab package
pushd build
    # copy metadata files
    cp -vr ../android/prefab-template/* prefab/

    # copy headers
    mkdir -vp prefab/modules/mp3lame/include
    cp -vt prefab/modules/mp3lame/include include/lame/*.h

    # copy libraries
    for ABI in ${ABIS[@]}; do
        cp -vt prefab/modules/mp3lame/libs/android.$ABI $ABI/lib/*.so
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
            --output $(pwd)/prefab-verification \
            $(pwd)/prefab)

        RESULT=$?; if [[ $RESULT == 0 ]]; then
            echo "$ABI: prefab package verified"
        else
            echo "$ABI: package package verification failed"
            exit 1
        fi

        rm -r prefab-verification/
    done
popd

# zip prefab/ and AndroidManifest.xml into an .aar
rm -r build/aar
mkdir -p build/aar

cp -rt build/aar/ build/prefab
cp -t build/aar/ android/AndroidManifest.xml

pushd build/aar
    zip -r ../lame-3.100.aar . > /dev/null
popd

# verify .aar and print output path to console
unzip -t build/lame-3.100.aar

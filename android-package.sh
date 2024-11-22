#!/usr/bin/env bash
ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")

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

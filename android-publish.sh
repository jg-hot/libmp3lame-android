#!/usr/bin/env bash
set -o xtrace

rm -rf build/

./android-build.sh
./android-package.sh

ARTIFACT="lame-3.100-android-r1"

mvn install:install-file \
    -Dfile=./build/$ARTIFACT.aar \
    -DpomFile=./android/$ARTIFACT.pom \
    -Dpackaging=aar \

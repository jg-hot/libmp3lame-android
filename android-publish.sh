#!/usr/bin/env bash
set -o xtrace

rm -rf build/

./android-build.sh
./android-package.sh

ARTIFACT="lame-android-3.100-android-r1"

mvn deploy:deploy-file \
    -Durl="https://maven.pkg.github.com/jg-hot/libmp3lame-android" \
    -DrepositoryId="gpr:libmp3lame-android" \
    -Dfile="./build/$ARTIFACT.aar" \
    -DpomFile="./android/$ARTIFACT.pom" \
    -Dpackaging=aar \

# or if installing to maven local
# mvn install:install-file \
#     -Dfile=./build/$ARTIFACT.aar \
#     -DpomFile=./android/$ARTIFACT.pom \
#     -Dpackaging=aar \

#!/bin/sh
set -eu

ROOT_DIR=$(dirname "$(realpath "$0")")

find packages -maxdepth 1 -mindepth 1 -exec basename {} \; | gum filter --header="Select packages to build" --no-limit | while IFS= read -r PKG; do
    gum choose --header="Select ABIs to build" --no-limit --selected="aarch64-linux-android" "aarch64-linux-android" "armv7a-linux-androideabi" "x86_64-linux-android" "i686-linux-android" | while read -r ABI; do
        echo "Building ${PKG} for ${ABI}"
        TARGET="${ABI}24" "${ROOT_DIR}/build-pkg.sh" "${PKG}"
    done
done

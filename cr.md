# Build PKGs

## build

```sh
#!/bin/sh
set -eu

msg() { printf '%s\n' "$*" >&2; }

ROOT="$(dirname "$(realpath "${MD_FILE}")")"
BUILD_ROOT="${ROOT}/build"
SOURCES_ROOT="${ROOT}/sources"
OUTPUT_ROOT="${ROOT}/output"
JOBS="$(nproc --all)"

export ROOT BUILD_ROOT SOURCES_ROOT OUTPUT_ROOT JOBS

echo $ANDROID_NDK_ROOT
TOOLCHAIN=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64
export CC=${TOOLCHAIN}/bin/clang
export CXX=${TOOLCHAIN}/bin/clang++
export LD=${TOOLCHAIN}/bin/ld.lld
export AR=${TOOLCHAIN}/bin/llvm-ar
export RANLIB=${TOOLCHAIN}/bin/llvm-ranlib
export STRIP=${TOOLCHAIN}/bin/llvm-strip
export OBJCOPY=${TOOLCHAIN}/bin/llvm-objcopy

ANDROID_ABI=aarch64-linux-android

setup_source() {
    case "${PKG_SRCURL}" in
    *.tar.gz) PKG_EXTNAME=.tar.gz ;;
    *.tar.xz) PKG_EXTNAME=.tar.xz ;;
    *.tar.bz2) PKG_EXTNAME=.tar.bz2 ;;
    *) ;;
    esac

    PKG_TARBALL="${SOURCES_ROOT}/${PKG_BASENAME}${PKG_EXTNAME}"

    if ! test -f "${PKG_TARBALL}"; then
        msg "Downloading ${PKG}..."
        if command -v curl >/dev/null; then
            DOWNLOAD_CMD="curl -Lk"
        elif command -v wget >/dev/null; then
            DOWNLOAD_CMD="wget -O-"
        else
            msg "Cannot find neither 'curl' nor 'wget'"
            exit 1
        fi
        ${DOWNLOAD_CMD} "${PKG_SRCURL}" >"${PKG_TARBALL}.tmp"
        mv "${PKG_TARBALL}.tmp" "${PKG_TARBALL}"
    fi

    case "${PKG_SRCURL}" in
    *.tar.gz) gzip -d <"${PKG_TARBALL}" | tar -C "${BUILD_PREFIX}" -x ;;
    *.tar.xz) xz -d <"${PKG_TARBALL}" | tar -C "${BUILD_PREFIX}" -x ;;
    *.tar.bz2) bzip2 -d <"${PKG_TARBALL}" | tar -C "${BUILD_PREFIX}" -x ;;
    *) ;;
    esac

    cd "${BUILD_PREFIX}/${PKG_BASENAME}"
}

build() {
    export PKG=$1
    export PKG_CONFIG_DIR="${ROOT}/pkgs/${PKG}"
    export md_conifg="${PKG_CONFIG_DIR}/build.md"
    export PKG_SRCURL=$(cr --file="${md_conifg}" --key=PKG_SRCURL)
    export PKG_BASENAME=$(cr --file="${md_conifg}" --key=PKG_BASENAME)
    export BUILD_PREFIX="${BUILD_PREFIX-${ROOT}/build/${ANDROID_ABI}}"

    mkdir -p "${BUILD_PREFIX}"

    setup_source
    # ${MD_EXE} --file=${MD_FILE} setup_source
    ${MD_EXE} --file="${md_conifg}" configure
    ${MD_EXE} --file="${md_conifg}" build
}

build "$@"

```

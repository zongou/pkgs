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

setup_target() {
    if test "${TARGET+1}"; then
        case "${TARGET}" in
        *-linux-android*)
            ANDROID_ABI="$(echo "${TARGET}" | grep -E -o -e '.+-.+-android(eabi)?')"
            ANDROID_API="$(echo "${TARGET}" | sed -E 's/.+-linux-android(eabi)?//')"
            export ANDROID_ABI ANDROID_API

            if ! test ${TOOLCHAIN+1} && test ${ANDROID_NDK_ROOT+1}; then
                TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64
            fi

            CC="${CC-${TOOLCHAIN}/bin/${TARGET}-clang}"
            CXX="${CXX-${TOOLCHAIN}/bin/${TARGET}-clang++}"
            LD="${LD-${TOOLCHAIN}/bin/ld.lld}"
            AR="${AR-${TOOLCHAIN}/bin/llvm-ar}"
            STRIP="${STRIP-${TOOLCHAIN}/bin/llvm-strip}"
            OBJCOPY="${OBJCOPY-${TOOLCHAIN}/bin/llvm-objcopy}"
            OBJDUMP="${OBJDUMP-${TOOLCHAIN}/bin/llvm-objdump}"
            RANLIB="${RANLIB-${TOOLCHAIN}/bin/llvm-ranlib}"
            ;;
        *) ;;
        esac

        BUILD_PREFIX="${BUILD_PREFIX-${ROOT}/build/${ANDROID_ABI}}"
        OUTPUT_DIR="${ROOT}/output/${ANDROID_ABI}"
    else
        CC=${CC-cc}
        CXX=${CXX-c++}
        LD=${LD-ld}
        AR=${AR-ar}
        STRIP=${STRIP-strip}
        OBJCOPY=${OBJCOPY-objcopy}
        OBJDUMP=${OBJDUMP-objdump}
        RANLIB=${RANLIB-ranlib}

        OUTPUT_DIR="${ROOT}/output/host"
        BUILD_PREFIX=${BUILD_ROOT}/host
    fi

    mkdir -p "${BUILD_PREFIX}"
    mkdir -p "${OUTPUT_DIR}" "${OUTPUT_DIR}/bin" "${OUTPUT_DIR}/lib"

    export CC CXX LD AR STRIP OBJCOPY OBJDUMP RANLIB
    export OUTPUT_DIR BUILD_PREFIX
    export PKG_CONFIG_PATH="${OUTPUT_DIR}/lib/pkgconfig" ## pkg-conf
    export FORCE_UNSAFE_CONFIGURE=1                      ## autoconf in PRoot enviroment
}

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
    PKG=$1
    PKG_CONFIG_DIR="${ROOT}/packages/${PKG}"
    md_conifg="${PKG_CONFIG_DIR}/build.md"
    PKG_SRCURL=$(${MD_EXE} --file="${md_conifg}" --key=PKG_SRCURL)
    PKG_BASENAME=$(${MD_EXE} --file="${md_conifg}" --key=PKG_BASENAME)

    export PKG PKG_CONFIG_DIR PKG_SRCURL PKG_BASENAME

    setup_target
    setup_source
    ${MD_EXE} --file="${md_conifg}" configure
    ${MD_EXE} --file="${md_conifg}" build
}

build "$@"

```

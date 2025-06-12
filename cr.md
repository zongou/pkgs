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

            BUILD_PREFIX="${BUILD_PREFIX-${BUILD_ROOT}/${ANDROID_ABI}}"
            OUTPUT_DIR="${ROOT}/output/${ANDROID_ABI}"
            ;;
        *)
            export ZIG_TARGET=${TARGET}
            CC=${CC-${ROOT}/tools/zig-as-llvm/bin/cc}
            CXX=${CXX-${ROOT}/tools/zig-as-llvm/bin/c++}
            LD=${LD-${ROOT}/tools/zig-as-llvm/bin/ld.lld}
            AR=${AR-${ROOT}/tools/zig-as-llvm/bin/ar}
            # STRIP=${STRIP-${ROOT}/tools/zig-as-llvm/bin/strip}
            OBJCOPY=${OBJCOPY-${ROOT}/tools/zig-as-llvm/bin/objcopy}
            # OBJDUMP=${OBJDUMP-objdump}
            RANLIB=${RANLIB-${ROOT}/tools/zig-as-llvm/bin/ranlib}

            BUILD_PREFIX="${BUILD_PREFIX-${BUILD_ROOT}/${TARGET}}"
            OUTPUT_DIR="${ROOT}/output/${TARGET}"
            ;;
        esac

    else
        CC=${CC-cc}
        CXX=${CXX-c++}
        LD=${LD-ld}
        AR=${AR-ar}
        STRIP=${STRIP-strip}
        OBJCOPY=${OBJCOPY-objcopy}
        OBJDUMP=${OBJDUMP-objdump}
        RANLIB=${RANLIB-ranlib}

        BUILD_PREFIX="${BUILD_PREFIX-${BUILD_ROOT}/host}"
        OUTPUT_DIR="${ROOT}/output/host"
    fi

    mkdir -p "${BUILD_PREFIX}"
    mkdir -p "${OUTPUT_DIR}" "${OUTPUT_DIR}/bin" "${OUTPUT_DIR}/lib"

    export CC CXX LD AR STRIP OBJCOPY OBJDUMP RANLIB
    export OUTPUT_DIR BUILD_PREFIX
    export PKG_CONFIG_PATH="${OUTPUT_DIR}/lib/pkgconfig" ## pkg-conf
    export FORCE_UNSAFE_CONFIGURE=1                      ## autoconf in PRoot enviroment
}

setup_golang() {
    if test "${TARGET+1}"; then
        ## Detect GOOS
        case "${TARGET}" in
        *-linux-android*) export GOOS=android CGO_ENABLED=1 ;;
        *-linux-musl*) export GOOS=linux ;;
        *) ;;
        esac

        ## Detect GOARCH
        case "${TARGET}" in
        aarch64-*) export GOARCH=arm64 ;;
        arm-*) export GOARCH=arm ;;
        x86_64-*) export GOARCH=amd64 ;;
        i686-*) export GOARCH=386 ;;
        *) ;;
        esac
    fi
}

setup_rust() {
    case "${TARGET}" in
    *-linux-android*)
        CARGO_BUILD_TARGET="$(echo "${ANDROID_ABI}" | sed 's/armv7a/armv7/')"
        export CARGO_BUILD_TARGET
        ;;
    aarch64-linux-musl)
        export CARGO_BUILD_TARGET=aarch64-unknown-linux-musl
        ;;
    aarch64-linux-gnu)
        export CARGO_BUILD_TARGET=aarch64-unknown-linux-gnu
        ;;
    x86_64-linux-gnu)
        export CARGO_BUILD_TARGET=x86_64-unknown-linux-gnu
        ;;
    x86_64-linux-musl)
        export CARGO_BUILD_TARGET=x86_64-unknown-linux-musl
        ;;
    *) ;;
    esac

    export "CARGO_TARGET_$(echo "${CARGO_BUILD_TARGET}" | tr "[:lower:]" "[:upper:]" | tr '-' '_')_LINKER=${CC}"
    export CARGO_BUILD_JOBS="${JOBS}"

    if command -v rustup >/dev/null && ! rustup target list --installed | grep -q "${CARGO_BUILD_TARGET}"; then
        rustup target add "${CARGO_BUILD_TARGET}"
    fi
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
    for env_key in PKG_SRCURL PKG_BASENAME PKG_VERSION PKG_HOMEPAGE PKG_DESCRIPTION PKG_LICENSE PKG_DEPENDS PKG_LANG; do
        if ${MD_EXE} --file="${md_conifg}" --key=${env_key} >/dev/null 2>&1; then
            export "${env_key}"="$(${MD_EXE} --file="${md_conifg}" --key=${env_key})"
        fi
    done

    if test "${PKG_LANG+1}"; then
        case "${PKG_LANG}" in
        go) setup_golang ;;
        rust) setup_rust ;;
        *) ;;
        esac
    fi

    setup_target
    setup_source

    for step in configure build; do
        if ${MD_EXE} --file="${md_conifg}" -c "${step}" >/dev/null 2>&1; then
            # msg "Running ${step}"
            ${MD_EXE} --file="${md_conifg}" "${step}"
        fi
    done
}

build "$@"

```

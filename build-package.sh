#!/bin/sh
set -eu

# shellcheck disable=SC2059
msg() { printf "%s\n" "$(test $# -eq 0 && cat || echo "$*")" >&2; }

WORK_DIR="$(dirname "$(realpath "$0")")"
SRCS_DIR=${WORK_DIR}/sources
mkdir -p "${SRCS_DIR}"
# shellcheck disable=SC2034
JOBS="$(nproc --all)"

## Prepare source and cd source dir
prepare_source() {
	PKG_TARBALL="${PKG_BASENAME}${PKG_EXTNAME}"
	if ! test -f "${SRCS_DIR}/${PKG_TARBALL}"; then
		msg "Downloading ${PKG_TARBALL}..."
		curl -Lk "${PKG_SRCURL}" >"${SRCS_DIR}/${PKG_TARBALL}.tmp"
		mv "${SRCS_DIR}/${PKG_TARBALL}.tmp" "${SRCS_DIR}/${PKG_TARBALL}"
	fi

	BUILDS_DIR=${WORK_DIR}/build/${ABI}
	mkdir -p "${BUILDS_DIR}"

	case "${PKG_EXTNAME}" in
	.tar.gz) gzip -d <"${SRCS_DIR}/${PKG_TARBALL}" | tar -C "${BUILDS_DIR}" -x ;;
	.tar.xz) xz -d <"${SRCS_DIR}/${PKG_TARBALL}" | tar -C "${BUILDS_DIR}" -x ;;
	.tar.bz2) bzip2 -d <"${SRCS_DIR}/${PKG_TARBALL}" | tar -C "${BUILDS_DIR}" -x ;;
	esac

	cd "${BUILDS_DIR}/${PKG_BASENAME}"
}

## Common android ABI: [aarch64-linux-android, armv7a-linux-androideabi, x86_64-linux-android, i686-linux-android]
setup_ndk_toolchain() {
	if ! test "${TOOLCHAIN+1}"; then
		if test "${ANDROID_NDK_HOME+1}"; then
			TOOLCHAIN="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64"
		fi
	fi

	export CC="${TOOLCHAIN}/bin/${ABI}${API}-clang"
	export CXX="${TOOLCHAIN}/bin/${ABI}${API}-clang++"

	for tool in ar objcopy ld lld strip objdump ranlib; do
		ENV_KEY=$(echo "${tool}" | tr "[:lower:]" "[:upper:]")
		for ENV_VAL in "${TOOLCHAIN}/bin/${TARGET}-${tool}" "${TOOLCHAIN}/bin/llvm-${tool}" "${TOOLCHAIN}/bin/${tool}"; do
			if test -x "${ENV_VAL}"; then
				export "${ENV_KEY}=${ENV_VAL}"
				break
			fi
		done
	done

	## pkg-conf
	export PKG_CONFIG_PATH="${OUTPUT_DIR}/lib/pkgconfig"

	## autoconf in PRoot enviroment
	export FORCE_UNSAFE_CONFIGURE=1
}

setup_golang() {
	case "${ABI}" in
	*-linux-android*)
		export CGO_ENABLED=1 GOOS=android
		case "${ABI}" in
		aarch64-linux-android) export GOARCH=arm64 ;;
		armv7a-linux-androideabi) export GOARCH=arm ;;
		x86_64-linux-android) export GOARCH=amd64 ;;
		i686-linux-android) export GOARCH=386 ;;
		esac
		;;
	esac
}

## Common rust android target: [aarch64-linux-android, x86_64-linux-android, armv7-linux-androideabi, i686-linux-android]
setup_rust() {
	CARGO_BUILD_TARGET="$(echo "${ABI}" | sed 's/armv7a/armv7/')"
	export CARGO_BUILD_TARGET

	## All rust supported android targets
	for rust_target in \
		aarch64-linux-android \
		arm-linux-androideabi \
		armv7-linux-androideabi \
		i686-linux-android \
		thumbv7neon-linux-androideabi \
		x86_64-linux-android; do
		export "CARGO_TARGET_$(echo "${rust_target}" | tr "[:lower:]" "[:upper:]" | tr '-' '_')_LINKER=${CC}"
	done

	if ! rustup target list --installed | grep -q "${CARGO_BUILD_TARGET}"; then
		rustup target add "${CARGO_BUILD_TARGET}"
	fi
}

build_depends() {
	if command -v depends >/dev/null; then
		depends | while read -r dependency; do
			## If depeds is not unset, subshell will has the same depends and cause dead loop.
			unset -f depends
			msg "Checking dependency: ${dependency} ..."
			(
				# shellcheck disable=SC1090
				. "${WORK_DIR}/packages/${dependency}/build.sh"
				if command -v check >/dev/null; then
					if check; then
						unset -f check
						msg "Check dependency ${dependency} passed."
					else
						unset -f check
						msg "Check dependency ${dependency} failed."
						build_packages "${dependency}"
					fi
				else
					msg "No Check method in package [${package}]"
				fi
			)
		done
	fi
}

build_packages() {
	(
		msg "Building package ${package} for ${ABI} ..."
		# shellcheck disable=SC2034
		PKG_CONFIG_DIR="${WORK_DIR}/packages/${package}"
		# shellcheck disable=SC1090
		. "${WORK_DIR}/packages/${package}/build.sh"
		build_depends

		(
			prepare_source
			for func in configure build; do
				if command -v "${func}" >/dev/null; then
					("${func}")
				fi
			done
		)
	)
}

main() {
	API=${API-24}
	ABI=${ABI-aarch64-linux-android}
	TARGET="${TARGET-${ABI}${API}}"

	# ABI="$(echo "${TARGET}" | grep -E -o -e '.+-.+-android(eabi)?')"
	API="$(echo "${TARGET}" | sed -E 's/.+-linux-android(eabi)?//')"

	OUTPUT_DIR="${WORK_DIR}/output/$(echo "${TARGET}" | grep -E -o ".+-linux-android(eabi)?")"
	export OUTPUT_DIR
	mkdir -p "${OUTPUT_DIR}"

	setup_ndk_toolchain

	for package in "$@"; do
		build_packages "${package}"
	done
}

main "$@"

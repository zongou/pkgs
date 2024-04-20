#!/bin/sh
## If no args arg given, build all pacakges.
## If args are given, take args as package name and build them.
set -eu

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

for ABI in aarch64-linux-android armv7a-linux-androideabi x86_64-linux-android i686-linux-android; do
	export ABI
	if test $# -gt 0; then
		for package in "$@"; do
			"${SCRIPT_DIR}/build-package.sh" "${package}"
		done
	else
		find "${SCRIPT_DIR}/packages" -maxdepth 1 -mindepth 1 -type d | while IFS= read -r dir; do
			package=$(basename "${dir}")
			"${SCRIPT_DIR}/build-package.sh" "${package}"
		done
	fi
done

## Dependencies is defined in libwebsocks
## Version is defined at cmake/GetGitVersion.cmake

## Type/Size			dynamic			static
## Without ssl 	 	720 KB			1.3 MB
## With mbedtls  	1.4 MB			2.0 MB
## With openssl  	4.8 MB			4.9 MB

PKG_HOMEPAGE=https://tsl0922.github.io/ttyd/
PKG_DESCRIPTION="Command-line tool for sharing terminal over the web"
PKG_LICENSE="MIT"

PKG_VERSION='1.7.7'
PKG_BASENAME=ttyd-main
PKG_EXTNAME=.tar.gz
PKG_SRCURL=https://github.com/zongou/ttyd/archive/refs/heads/main${PKG_EXTNAME}

PKG_DEPENDS="zlib json-c libwebsocks"

configure() {
	rm -rf build && mkdir build && cd build
	STATIC_FLAGS="-static -ldl"
	cmake \
		-DCMAKE_FIND_ROOT_PATH="${OUTPUT_DIR}" \
		-DCMAKE_INSTALL_PREFIX="${OUTPUT_DIR}" \
		-DCMAKE_BUILD_TYPE=RELEASE \
		-DCMAKE_FIND_LIBRARY_SUFFIXES=".a" \
		-DCMAKE_C_FLAGS="-Os -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables ${STATIC_FLAGS+${STATIC_FLAGS}}" \
		-DCMAKE_EXE_LINKER_FLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections ${STATIC_FLAGS+${STATIC_FLAGS}}" \
		..
}

build() {
	make install
	
	du -ahd0 "${OUTPUT_DIR}/bin/ttyd"
	if command -v file >/dev/null; then
		file "${OUTPUT_DIR}/bin/ttyd"
	fi
}

check() {
	test -f "${OUTPUT_DIR}/bin/ttyd"
}

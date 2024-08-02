PKG_HOMEPAGE=https://tukaani.org/xz/
PKG_DESCRIPTION="XZ-format compression library"
PKG_LICENSE="LGPL-2.1, GPL-2.0, GPL-3.0"
PKG_LICENSE_FILE="COPYING, COPYING.GPLv2, COPYING.GPLv3, COPYING.LGPLv2.1"
PKG_VERSION="18.1.8"
PKG_SRCURL=https://github.com/llvm/llvm-project/releases/download/llvmorg-${PKG_VERSION}/llvm-project-${PKG_VERSION}.src.tar.xz

PKG_BASENAME=llvm-project-${PKG_VERSION}.src

# configure() {
# 	# ## Small build, stripped
# 	# export CFLAGS="-Os -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables"
# 	# export LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"

# 	# export LDFLAGS="-w -s"
# 	# ./configure \
# 	# 	--enable-static \
# 	# 	--disable-shared \
# 	# 	--enable-sandbox=no \
# 	# 	--prefix="${OUTPUT_DIR}" \
# 	# 	--host="${TARGET}"

# 	# sudo apt install ninja-build binfmt-support qemu-user-static

# 	export CC="${ROOT_DIR}/wrappers/zig/bin/cc --target=${TARGET}"
# 	export CC="${ROOT_DIR}/wrappers/zig/bin/c++ --target=${TARGET}"
# 	export LDFLAGS="-s"

# 	mkdir -p build && cd build || exit

# 	cmake ../llvm \
# 		-G Ninja \
# 		-DCMAKE_BUILD_TYPE=Release \
# 		-DCMAKE_INSTALL_PREFIX="${PWD}/output" \
# 		-DLLVM_ENABLE_PROJECTS="clang-tools-extra" \
# 		-DLLVM_TARGETS_TO_BUILD="all" \
# 		-DLLVM_HOST_TRIPLE="${TARGET}" \
# 		-DCMAKE_SKIP_INSTALL_RPATH=TRUE

# }

# build() {
# 	cmake --build . --target install
# }

# # check() {
# # 	test -f "${OUTPUT_DIR}/lib/liblzma.a"
# # }

PKG_DEPENDS="zlib zstd"

configure() {
	ls
}

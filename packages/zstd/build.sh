TERMUX_PKG_HOMEPAGE=https://github.com/facebook/zstd
TERMUX_PKG_DESCRIPTION="Zstandard compression"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.5.6"
TERMUX_PKG_SRCURL=https://github.com/facebook/zstd/archive/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=30f35f71c1203369dc979ecde0400ffea93c27391bfd2ac5a9715d2173d92ff7
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="liblzma, zlib"
TERMUX_PKG_BREAKS="zstd-dev"
TERMUX_PKG_REPLACES="zstd-dev"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Ddefault_library=both
-Dbin_programs=true
-Dbin_tests=false
-Dbin_contrib=true
-Dzlib=enabled
-Dlzma=enabled
-Dlz4=disabled
"

# # Is this needed?
# TERMUX_PKG_RM_AFTER_INSTALL="
# bin/zstd-frugal
# "

# termux_step_pre_configure() {
# 	TERMUX_PKG_SRCDIR+="/build/meson"

# 	# SOVERSION suffix is needed for backward compatibility. Do not remove
# 	# this (and the guard in the post-massage step) unless you know what
# 	# you are doing. `zstd` is a dependency of `apt` to which something
# 	# catastrophic could happen if you are careless.
# 	export TERMUX_MESON_ENABLE_SOVERSION=1
# }

# termux_step_post_massage() {
# 	# Do not forget to bump revision of reverse dependencies and rebuild them
# 	# after SOVERSION is changed.
# 	local _SOVERSION_GUARD_FILES="lib/libzstd.so.1"
# 	local f
# 	for f in ${_SOVERSION_GUARD_FILES}; do
# 		if [ ! -e "${f}" ]; then
# 			termux_error_exit "SOVERSION guard check failed."
# 		fi
# 	done
# }

build() {
	cp "$ROOTDIR/zstd/lib/zstd.h" "${TARGET_INSTALL_DIR}/include/zstd.h"
	cd "${TARGET_INSTALL_DIR}/lib"
	zig build-lib \
		--name zstd \
		-target "$TARGET" \
		-mcpu="$MCPU" \
		-fstrip -OReleaseFast \
		-lc \
		"$ROOTDIR/zstd/lib/decompress/zstd_ddict.c" \
		"$ROOTDIR/zstd/lib/decompress/zstd_decompress.c" \
		"$ROOTDIR/zstd/lib/decompress/huf_decompress.c" \
		"$ROOTDIR/zstd/lib/decompress/huf_decompress_amd64.S" \
		"$ROOTDIR/zstd/lib/decompress/zstd_decompress_block.c" \
		"$ROOTDIR/zstd/lib/compress/zstdmt_compress.c" \
		"$ROOTDIR/zstd/lib/compress/zstd_opt.c" \
		"$ROOTDIR/zstd/lib/compress/hist.c" \
		"$ROOTDIR/zstd/lib/compress/zstd_ldm.c" \
		"$ROOTDIR/zstd/lib/compress/zstd_fast.c" \
		"$ROOTDIR/zstd/lib/compress/zstd_compress_literals.c" \
		"$ROOTDIR/zstd/lib/compress/zstd_double_fast.c" \
		"$ROOTDIR/zstd/lib/compress/huf_compress.c" \
		"$ROOTDIR/zstd/lib/compress/fse_compress.c" \
		"$ROOTDIR/zstd/lib/compress/zstd_lazy.c" \
		"$ROOTDIR/zstd/lib/compress/zstd_compress.c" \
		"$ROOTDIR/zstd/lib/compress/zstd_compress_sequences.c" \
		"$ROOTDIR/zstd/lib/compress/zstd_compress_superblock.c" \
		"$ROOTDIR/zstd/lib/deprecated/zbuff_compress.c" \
		"$ROOTDIR/zstd/lib/deprecated/zbuff_decompress.c" \
		"$ROOTDIR/zstd/lib/deprecated/zbuff_common.c" \
		"$ROOTDIR/zstd/lib/common/entropy_common.c" \
		"$ROOTDIR/zstd/lib/common/pool.c" \
		"$ROOTDIR/zstd/lib/common/threading.c" \
		"$ROOTDIR/zstd/lib/common/zstd_common.c" \
		"$ROOTDIR/zstd/lib/common/xxhash.c" \
		"$ROOTDIR/zstd/lib/common/debug.c" \
		"$ROOTDIR/zstd/lib/common/fse_decompress.c" \
		"$ROOTDIR/zstd/lib/common/error_private.c" \
		"$ROOTDIR/zstd/lib/dictBuilder/zdict.c" \
		"$ROOTDIR/zstd/lib/dictBuilder/divsufsort.c" \
		"$ROOTDIR/zstd/lib/dictBuilder/fastcover.c" \
		"$ROOTDIR/zstd/lib/dictBuilder/cover.c"
}

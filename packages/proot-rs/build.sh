## zig objcopy currently is not compatible to strip

PKG_HOMEPAGE=https://proot-me.github.io/
PKG_DESCRIPTION="Emulate chroot, bind mount and binfmt_misc for non-root users"
PKG_LICENSE="GPL-2.0"

PKG_VERSION=0.1.0
PKG_BASENAME=proot-rs-${PKG_VERSION}
PKG_SRCURL=https://github.com/proot-me/proot-rs/archive/refs/tags/v${PKG_VERSION}.tar.gz

BUILD_PREFIX="${SCRIPT_DIR}/build/rust"

build() {
	sed -i 's^https://github.com^https://ghproxy.net/https://github.com^g' Cargo.toml
	sed -i 's^https://github.com^https://ghproxy.net/https://github.com^g' Cargo.lock
	sed -i 's^https://github.com^https://ghproxy.net/https://github.com^g' loader-shim/Cargo.toml
	touch proot-rs/src/kernel/execve/loader-shim
	cargo clippy
	cargo build --release

	# ## Add to toolchain search dirs
	# export CFLAGS="-I${OUTPUT_DIR}/include"
	# export LDFLAGS="-L${OUTPUT_DIR}/lib"

	# ## Make small size stripped
	# export CFLAGS="${CFLAGS} -Os -ffunction-sections -fdata-sections -fno-unwind-tables -fno-asynchronous-unwind-tables"
	# export LDFLAGS="${LDFLAGS} -ffunction-sections -fdata-sections -Wl,--gc-sections -s"

	# ## Make static linked
	# export LDFLAGS="${LDFLAGS} -static"

	# ## Make loader unbundled
	# # export PROOT_UNBUNDLE_LOADER='../libexec/proot'

	# make -C src distclean || true
	# make -C src V=1 "PREFIX=${OUTPUT_DIR}" ${STRIP+STRIP="${STRIP}"} -j"${JOBS}" install
}

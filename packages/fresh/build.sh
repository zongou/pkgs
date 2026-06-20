PKG_HOMEPAGE=https://github.com/sinelaw/fresh
PKG_DESCRIPTION="Terminal based IDE & text editor: easy, powerful and fast"
PKG_LICENSE="GPL-2.0"

PKG_VERSION="0.4.1"
PKG_EXTNAME=.tar.gz
PKG_NAME=fresh
PKG_BASENAME=${PKG_NAME}-${PKG_VERSION}
PKG_SRCURL=https://github.com/sinelaw/fresh/archive/refs/tags/v${PKG_VERSION}${PKG_EXTNAME}

build() {
	setup_rust
	# export RUSTFLAGS="-C link-arg=-s -C opt-level=s -C lto=true"
	cargo build --release
	install "target/${CARGO_BUILD_TARGET}/release/${PKG_NAME}" -D "${OUTPUT_DIR}/bin/${PKG_NAME}"
}

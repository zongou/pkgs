
PKG_HOMEPAGE="https://github.com/Watfaq/clash-rs"
PKG_DESCRIPTION="A post-modern modal text editor written in rust"
PKG_LICENSE="MPL-2.0"

PKG_VERSION="0.2.0"
PKG_NAME=clash-rs
PKG_SRCURL=https://github.com/Watfaq/clash-rs/archive/refs/tags/v0.2.0.tar.gz
PKG_BASENAME=${PKG_NAME}-${PKG_VERSION}
BUILD_PREFIX="${RUST_BUILD_DIR}"

build() {
	ls
	setup_rust
	cargo build --release --target "${CARGO_BUILD_TARGET}"
}

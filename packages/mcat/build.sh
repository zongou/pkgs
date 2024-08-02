PKG_HOMEPAGE=https://github.com/Skardyy/mcat
PKG_DESCRIPTION="erminal image, video, and Markdown viewer"
PKG_LICENSE="MIT"

PKG_VERSION="0.6.2"
PKG_EXTNAME=.tar.gz
PKG_NAME=mcat
PKG_BASENAME=${PKG_NAME}-${PKG_VERSION}
PKG_SRCURL=https://github.com/Skardyy/mcat/archive/refs/tags/v${PKG_VERSION}${PKG_EXTNAME}

build() {
	setup_rust
	# export RUSTFLAGS="-C link-arg=-s -C opt-level=s -C lto=true"
	cargo build --release
	install "target/${CARGO_BUILD_TARGET}/release/${PKG_NAME}" -D "${OUTPUT_DIR}/bin/${PKG_NAME}"
}

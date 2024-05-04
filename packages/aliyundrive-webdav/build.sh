PKG_HOMEPAGE=https://github.com/messense/aliyundrive-webdav
PKG_DESCRIPTION="AliyunDrive webdav service"
PKG_LICENSE="MIT"

PKG_VERSION="2.3.3"
PKG_EXTNAME=.tar.gz
PKG_NAME=aliyundrive-webdav
PKG_BASENAME=${PKG_NAME}-${PKG_VERSION}
PKG_SRCURL=https://github.com/messense/aliyundrive-webdav/archive/refs/tags/v${PKG_VERSION}${PKG_EXTNAME}

build() {
	setup_rust_toolchain
	export RUSTFLAGS="-C link-arg=-s -C opt-level=s -C lto=true"
	cargo build --release
	install "target/${CARGO_BUILD_TARGET}/release/${PKG_NAME}" -D "${OUTPUT_DIR}/bin/${PKG_NAME}"
}
